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
pnpm create @eslint/config
cat > pnpm-workspace.yaml <<EOF
packages:
  - packages/*
EOF
pnpm add json husky @commitlint/{config-conventional,cli} lint-staged -w -D
pnpm exec json -I -f package.json -e 'this.private = true'
pnpm exec json -I -f package.json -e 'this.scripts["prepare"] = "husky install"'
pnpm exec json -I -f package.json -e 'this["lint-staged"] = {"*.{ts,tsx,js,vue}": "pnpm exec eslint --fix"}'
pnpm run prepare
pnpm exec husky add .husky/commit-msg 'pnpm exec commitlint --edit "$1"'
pnpm exec husky add .husky/pre-commit 'pnpm exec lint-staged'

cat > commitlint.config.js <<EOF
module.exports = {
    extends: ["@commitlint/config-conventional"],
    rules: {}
}
EOF
cat > .eslintignore <<EOF
node_modules
.eslintrc.js
commitlint.config.js
EOF
touch .npmrc .nvmrc
mkdir -p packages
