#!/usr/bin/env bash

read -p "请输入文件夹名称: " folder_name
mkdir $folder_name
cd $folder_name
mkdir src
mkdir public
touch src/index.js
touch public/index.html
npm init -y
cat > public/index.html <<EOF
<html>
  <head>
    <title><%=htmlWebpackPlugin.options.title%></title>
  </head>
  <body>
  </body>
</html>
EOF
cat > src/index.js <<EOF
console.log('HELLO')
EOF
cat > webpack.config.js <<EOF
const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
module.exports = {
  mode: 'development',
  entry: {
      main: './src/index.js',
  },
  output: {
      filename: '[name].[hash].js',
      path:path.resolve(__dirname, 'dist'),
      clean: true
  },
  plugins: [
      new HtmlWebpackPlugin({
          template: './public/index.html',
          minify: true,
          filename: 'index.html',
          title: 'HELLO',
          inject: 'body'
      })
  ],
  devServer: {
    hot: true,
    port: 8888
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: 'babel-loader'
      }
    ] 
  }
}
EOF
npm install webpack webpack-cli webpack-dev-server html-webpack-plugin -D
npm install @babel/core @babel/cli babel-loader -D
npm install json -D
npx json -I -f package.json -e 'this.scripts["build"] = "webpack"'
npx json -I -f package.json -e 'this.scripts["dev"] = "webpack serve"'
echo "成功了"
