#!/bin/bash
#git初始化
if [ ! -d .git ]; then
    git init
fi
#初始化.gitignore
cat > .gitignore <<EOF
node_modules
monorepo.sh
EOF
#初始化项目
pnpm init
pnpm add typescript
pnpm create @eslint/config
cat > pnpm-workspace.yaml <<EOF
packages:
  - packages/*
EOF
#实现commit约束(支持自定义)
pnpm add commitizen cz-conventional-changelog commitlint-config-cz cz-customizable @commitlint/{config-conventional,cli} -w -D
pnpm add standard-version json husky  lint-staged -w -D
pnpm exec json -I -f package.json -e 'this.private = true'
pnpm exec json -I -f package.json -e 'this.scripts["prepare"] = "husky install"'
pnpm exec json -I -f package.json -e 'this.scripts["release"] = "standard-version"'
pnpm exec json -I -f package.json -e 'this.scripts["commit"] = "pnpm exec git cz"'
pnpm exec json -I -f package.json -e 'this["lint-staged"] = {"*.{ts,tsx,js,vue}": "pnpm exec eslint --fix"}'
pnpm run prepare
pnpm exec husky add .husky/commit-msg 'pnpm exec commitlint --edit "$1"'
pnpm exec husky add .husky/pre-commit 'pnpm exec lint-staged'
#利用cz-customizable实现自定义commit格式
echo '{"path": "cz-customizable"}' > .czrc
cat > .cz-config.js <<EOF
const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const packages = fs
.readdirSync(path.resolve(__dirname, 'packages'), { withFileTypes: true })
.filter(file => file.isDirectory())
.map(m => m.name);

const defaultScope = execSync('git status --porcelain || true')
.toString()
.trim()
.split('\n')
.find((r) => r.indexOf('M  ') >= 0)
?.replace(/(\/)/g, '%')
?.match(/packages%((\w|-)*)/)?.[1];
module.exports = {
	types: [
		{ value: 'init',     name: 'init:     初始提交' },
		{ value: 'feat',     name: 'feat:     增加新功能' },
		{ value: 'fix',      name: 'fix:      修复bug' },
		{ value: 'refactor', name: 'refactor: 代码重构' },
		{ value: 'release',  name: 'release:  发布' },
		{ value: 'deploy',   name: 'deploy:   部署' },
        { value: 'ci',       name: 'ci:       持续集成'},
		{ value: 'docs',     name: 'docs:     修改文档' },
		{ value: 'test',     name: 'test:     单元测试' },
		{ value: 'chore',    name: 'chore:    更改配置文件' },
		{ value: 'style',    name: 'style:    样式修改不影响逻辑' },
		{ value: 'revert',   name: 'revert:   版本回退' },
		{ value: 'depend',   name: 'depend:   依赖调整' },
		{ value: 'minus',    name: 'minus:    版本回退' },
		{ value: 'del',      name: 'del:      删除代码/文件' }
	],
	scopes: [
		...packages,
    'project'
	],
	messages: {
		type: '选择更改类型:\n',
		// 如果allowcustomscopes为true，则使用
		scope: '当前提交修改的scope:\n',
		// customScope: '请输入自定义的scope:',
		subject: '简短描述(必填):\n',
		body: '详细描述. 使用"|"换行:\n',
		breaking: '破坏性更新列表:\n',
		footer: '关闭的issues列表. E.g.: #31, #34:\n',
		confirmCommit: '确认提交?'
	},
	subjectLimit: 200, 
	defaultScope,
	allowCustomScopes: true,
	allowBreakingChanges: ['feat', 'fix'],
}
EOF
# commitlint对用户自定义的规范校验提供支持
cat > commitlint.config.js <<EOF
module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {
		// Header
		'header-max-length': [2, 'always', 200],
		// <type>枚举
		'type-enum': [
			2,
			'always',
			[
        'init',
        'feat',
        'fix',
        'refactor',
        'release',
        'deploy',
        'ci',
        'docs',
        'test',
        'chore',
        'style',
        'revert',
        'depend',
        'minus',
        'del'
			]
		],
		// <type> 不能为空
		'type-empty': [2, 'never'],
		// <type> 格式 小写
		'type-case': [2, 'always', 'lower-case'],
		// <scope> 不能为空
		// 'scope-empty': [2, 'never'],
		// <scope> 格式 小写
		'scope-case': [2, 'always', 'lower-case'],
		// <subject> 不能为空
		'subject-empty': [2, 'never'],
		// <subject> 以.为结束标志
		'subject-full-stop': [2, 'never', '.'],
		// <subject> 格式
		// 可选值
		// 'lower-case' 小写 lowercase
		// 'upper-case' 大写 UPPERCASE
		// 'camel-case' 小驼峰 camelCase
		// 'kebab-case' 短横线 kebab-case
		// 'pascal-case' 大驼峰 PascalCase
		// 'sentence-case' 首字母大写 Sentence case
		// 'snake-case' 下划线 snake_case
		// 'start-case' 所有首字母大写 start-case
		'subject-case': [2, 'never', []],
		// <body> 以空行开头
		'body-leading-blank': [1, 'always'],
		// <footer> 以空行开头
		'footer-leading-blank': [1, 'always']
	}
}
EOF

cat > .eslintignore <<EOF
node_modules
.eslintrc.js
commitlint.config.js
EOF
touch .npmrc .nvmrc
mkdir -p packages
cat > .editorconfig <<EOF
root = true

# Unix-style newlines with a newline ending every file
[*]
end_of_line = lf
indent_size = 4
EOF

#允许eslint使用require
#"@typescript-eslint/no-var-requires": 0
