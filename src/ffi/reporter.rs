//! FFI functions for reporter lifecycle management

use super::types::{SmConfig, SmReporter, SmStatus};
use crate::services::Reporter;
use std::ffi::CStr;
use std::sync::{Arc, Mutex, Once};
use tracing::{info, error};
use tokio::runtime::Runtime;

/// Global storage for the reporter instance
static GLOBAL_REPORTER: Mutex<Option<ReporterHandle>> = Mutex::new(None);

/// Global tokio runtime
static mut GLOBAL_RUNTIME: Option<Runtime> = None;
static RUNTIME_INIT: Once = Once::new();

type ReporterHandle = Arc<Reporter>;

/// Initialize the global tokio runtime
fn get_runtime() -> &'static Runtime {
    unsafe {
        RUNTIME_INIT.call_once(|| {
            GLOBAL_RUNTIME = Some(
                Runtime::new().expect("Failed to create tokio runtime")
            );
        });
        GLOBAL_RUNTIME.as_ref().unwrap()
    }
}

/// Start the reporter with the given configuration
///
/// # Arguments
/// * `config` - Pointer to SmConfig struct (will not be modified or freed)
///
/// # Returns
/// * Non-null pointer - Handle to the running reporter (opaque)
/// * Null pointer - Failed to start reporter (config was null or reporter already running)
///
/// # Safety
/// The returned pointer must be passed to sm_reporter_stop to clean up resources
#[no_mangle]
pub extern "C" fn sm_reporter_start(config: *const SmConfig) -> *mut SmReporter {
    if config.is_null() {
        error!("sm_reporter_start: null config pointer");
        return std::ptr::null_mut();
    }

    // Initialize runtime
    let _rt = get_runtime();

    // Check if reporter is already running
    {
        let guard = GLOBAL_REPORTER.lock().unwrap();
        if guard.is_some() {
            error!("sm_reporter_start: reporter already running");
            return std::ptr::null_mut();
        }
    }

    let (enabled, ws_url, token) = unsafe {
        let cfg = &*config;
        (
            cfg.enabled,
            CStr::from_ptr(cfg.ws_url).to_string_lossy().to_string(),
            CStr::from_ptr(cfg.token).to_string_lossy().to_string(),
        )
    };

    let reporter_config = crate::services::ReporterConfig {
        enabled,
        ws_url,
        token,
    };

    // Create reporter within the runtime context
    let reporter = Reporter::new(reporter_config);

    // Store the reporter globally
    {
        let mut guard = GLOBAL_REPORTER.lock().unwrap();
        *guard = Some(Arc::new(reporter));
    }

    info!("Reporter started successfully");

    // Return a non-null pointer as a handle (the actual value doesn't matter,
    // we just use it as a token to indicate the reporter is running)
    Box::into_raw(Box::new(())) as *mut SmReporter
}

/// Stop the running reporter
///
/// # Arguments
/// * `handle` - Handle returned by sm_reporter_start
///
/// # Returns
/// * `true` - Reporter stopped successfully
/// * `false` - Failed to stop (invalid handle or reporter not running)
#[no_mangle]
pub extern "C" fn sm_reporter_stop(_handle: *mut SmReporter) -> bool {
    // We ignore the actual handle value and just check if a reporter is running
    let mut guard = GLOBAL_REPORTER.lock().unwrap();
    if guard.is_some() {
        *guard = None;
        info!("Reporter stopped successfully");
        true
    } else {
        error!("sm_reporter_stop: no reporter running");
        false
    }
}

/// Get the current status of the reporter
///
/// # Arguments
/// * `handle` - Handle returned by sm_reporter_start (ignored but kept for API consistency)
///
/// # Returns
/// * SmStatus struct containing the current status
#[no_mangle]
pub extern "C" fn sm_reporter_get_status(_handle: *const SmReporter) -> SmStatus {
    let guard = GLOBAL_REPORTER.lock().unwrap();

    let is_running = guard.is_some();
    // For now, we assume connected if running (WebSocket status could be added later)
    let is_connected = is_running;

    SmStatus {
        is_running,
        is_connected,
        last_error: std::ptr::null_mut(),
    }
}

/// Check if the reporter is currently running
///
/// # Returns
/// * `true` - Reporter is running
/// * `false` - Reporter is not running
#[no_mangle]
pub extern "C" fn sm_reporter_is_running() -> bool {
    let guard = GLOBAL_REPORTER.lock().unwrap();
    guard.is_some()
}

// Note: We don't implement sm_reporter_free since the handle is just a token
// and the actual cleanup happens in sm_reporter_stop
