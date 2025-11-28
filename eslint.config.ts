import antfu from "@antfu/eslint-config";

const atf = antfu({
	vue: true,
	typescript: true,
	formatters: true,
	stylistic: {
		indent: "tab",
		quotes: "double",
		semi: true,
	},
	rules: {
		"antfu/top-level-function": "off",
		"no-undef": "off",
		"eslinttailwindcss/no-custom-classname": "off",
		"no-console": ["warn", { allow: ["warn", "error"] }],
		"brace-style": ["error", "1tbs", { allowSingleLine: true }],
	},
});

export default atf;
