<script setup lang="ts">
import { getCurrentWindow } from "@tauri-apps/api/window";
import gsap from "gsap";
import { nextTick, ref } from "vue";
import "@/assets/main.css";

const isDragging = ref(false);
const showCapsuleMenu = ref(false);
const isPinned = ref(false);
const capsuleRef = ref<HTMLElement | null>(null);

// 使用 Tauri API 实现窗口拖动
const startDrag = async () => {
	isDragging.value = true;
	try {
		const window = getCurrentWindow();
		await window.startDragging();
	} catch (e) {
		console.error("拖动失败:", e);
	} finally {
		// 延迟重置状态，让动画有时间播放
		setTimeout(() => {
			isDragging.value = false;
		}, 150);
	}
};

// 双击打开/关闭胶囊菜单
const handleDoubleClick = async () => {
	showCapsuleMenu.value = !showCapsuleMenu.value;
	if (showCapsuleMenu.value) {
		await nextTick();
		// 入场动画
		if (capsuleRef.value) {
			gsap.fromTo(capsuleRef.value, { opacity: 0, scale: 0.8, y: -10 }, { opacity: 1, scale: 1, y: 0, duration: 0.3, ease: "back.out(1.7)" });
			// 按钮依次入场
			const buttons = capsuleRef.value.querySelectorAll(".capsule-btn");
			gsap.fromTo(buttons, { opacity: 0, scale: 0.5 }, { opacity: 1, scale: 1, duration: 0.2, stagger: 0.05, ease: "back.out(2)", delay: 0.1 });
		}
	}
};

// 关闭胶囊菜单（带动画）
const closeCapsuleMenu = () => {
	if (capsuleRef.value) {
		gsap.to(capsuleRef.value, {
			opacity: 0,
			scale: 0.8,
			y: -10,
			duration: 0.2,
			ease: "power2.in",
			onComplete: () => {
				showCapsuleMenu.value = false;
			},
		});
	} else {
		showCapsuleMenu.value = false;
	}
};

// 窗口操作
const handleClose = async () => {
	closeCapsuleMenu();
	setTimeout(async () => {
		const window = getCurrentWindow();
		await window.close();
	}, 200);
};

const handleMinimize = async () => {
	closeCapsuleMenu();
	const window = getCurrentWindow();
	await window.minimize();
};

const handlePin = async () => {
	const window = getCurrentWindow();
	isPinned.value = !isPinned.value;
	await window.setAlwaysOnTop(isPinned.value);
};

// 点击外部关闭菜单
const handleClickOutside = (e: MouseEvent) => {
	if (!showCapsuleMenu.value)
		return;
	const target = e.target as HTMLElement;
	if (!target.closest(".capsule-menu")) {
		closeCapsuleMenu();
	}
};
</script>

<template>
	<div class="app-container" @click="handleClickOutside">
		<!-- 顶部拖拽区域 - 使用 mousedown 触发拖动，双击打开菜单 -->
		<div
			class="drag-handle" :class="{ dragging: isDragging }" @mousedown="startDrag"
			@dblclick.stop="handleDoubleClick"
		>
			<div class="drag-indicator">
				<span class="indicator-dot" />
				<span class="indicator-line" />
				<span class="indicator-dot" />
			</div>
		</div>

		<!-- 胶囊操作菜单 -->
		<div v-if="showCapsuleMenu" ref="capsuleRef" class="capsule-menu" @click.stop>
			<button class="capsule-btn close" title="关闭" @click="handleClose">
				<Icon name="mdi:close" />
			</button>
			<button class="capsule-btn minimize" title="最小化" @click="handleMinimize">
				<Icon name="mdi:minus" />
			</button>
			<button class="capsule-btn pin" :class="{ active: isPinned }" title="置顶" @click="handlePin">
				<Icon name="mdi:pin" />
			</button>
		</div>

		<div class="content-area">
			<NuxtPage />
		</div>
	</div>
</template>

<style lang="scss">
$transition-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

.app-container {
	width: 100%;
	height: 100vh;
	display: flex;
	flex-direction: column;
	background: transparent;
	overflow: hidden;
}

.drag-handle {
	width: 100%;
	height: 36px;
	display: flex;
	align-items: center;
	justify-content: center;
	cursor: grab;
	flex-shrink: 0;
	position: relative;
	z-index: 1000;

	&:active,
	&.dragging {
		cursor: grabbing;
	}

	// 指示器容器
	.drag-indicator {
		display: flex;
		align-items: center;
		gap: 4px;
		padding: 6px 12px;
		border-radius: 100px;
		transition: all 0.25s $transition-spring;
	}

	&:hover .drag-indicator {
		background: rgba(128, 128, 128, 0.1);
		transform: scale(1.05);
	}

	&:active .drag-indicator,
	&.dragging .drag-indicator {
		background: rgba(128, 128, 128, 0.15);
		transform: scale(0.95);
	}

	// 小圆点
	.indicator-dot {
		width: 5px;
		height: 5px;
		background: var(--text-tertiary);
		border-radius: 50%;
		opacity: 0;
		transform: scale(0);
		transition: all 0.25s $transition-spring;
	}

	&:hover .indicator-dot {
		opacity: 0.6;
		transform: scale(1);
	}

	&:active .indicator-dot,
	&.dragging .indicator-dot {
		opacity: 0.8;
		transform: scale(1.2);
		background: var(--accent-color);
	}

	// 横线
	.indicator-line {
		width: 36px;
		height: 5px;
		background: var(--text-tertiary);
		border-radius: 100px;
		opacity: 0.4;
		transition: all 0.25s $transition-spring;
	}

	&:hover .indicator-line {
		width: 44px;
		opacity: 0.6;
		background: var(--text-secondary);
	}

	&:active .indicator-line,
	&.dragging .indicator-line {
		width: 32px;
		opacity: 0.9;
		background: var(--accent-color);
		box-shadow: 0 0 8px rgba(0, 122, 255, 0.4);
	}
}

// 胶囊操作菜单
.capsule-menu {
	position: absolute;
	top: 40px;
	left: 50%;
	transform: translateX(-50%);
	display: flex;
	align-items: center;
	gap: 8px;
	padding: 8px 12px;
	background: var(--bg-glass);
	backdrop-filter: blur(24px);
	-webkit-backdrop-filter: blur(24px);
	border: 1px solid var(--border-glass);
	border-radius: 100px;
	box-shadow:
		0 8px 32px rgba(0, 0, 0, 0.12),
		0 2px 8px rgba(0, 0, 0, 0.08);
	z-index: 1001;
}

.capsule-btn {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 32px;
	height: 32px;
	border: none;
	border-radius: 50%;
	background: rgba(128, 128, 128, 0.1);
	color: var(--text-secondary);
	cursor: pointer;
	transition: all 0.2s $transition-spring;
	font-size: 16px;

	&:hover {
		transform: scale(1.1);
		background: rgba(128, 128, 128, 0.2);
		color: var(--text-primary);
	}

	&:active {
		transform: scale(0.95);
	}

	// 关闭按钮
	&.close:hover {
		background: rgba(255, 59, 48, 0.2);
		color: #ff3b30;
	}

	// 最小化按钮
	&.minimize:hover {
		background: rgba(255, 204, 0, 0.2);
		color: #ffcc00;
	}

	// 置顶按钮
	&.pin:hover {
		background: rgba(0, 122, 255, 0.2);
		color: var(--accent-color);
	}

	&.pin.active {
		background: rgba(0, 122, 255, 0.25);
		color: var(--accent-color);

		&:hover {
			background: rgba(0, 122, 255, 0.35);
		}
	}
}

.content-area {
	flex: 1;
	overflow: auto;
}
</style>
