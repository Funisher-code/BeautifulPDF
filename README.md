# BeautifulPDF
Using image DPI corrections, Pandoc and Eisvogel to create beautiful Markdown PDF Exports

## Usage
```bash
./beautifulPDF.sh -i someMarkdownFile.md -o beautiful.pdf
```

## Example Yaml Header
```yaml
---
title: "This is the Title of the Article"
author: [Markus Mächler]
date: "2022-XX-XX"
subject: "Markdown"
keywords: [Markdown, Example]
subtitle: "And here you can see the subtitle"
lang: "en"
titlepage: true
titlepage-color: "FFAF1B"
#titlepage-color: "FFFFFF"
titlepage-text-color: "000000"
titlepage-rule-color: "000000"
titlepage-rule-height: 2
#titlepage-background: "background.pdf"
---
```

## Installation
dependencies:
```bash
brew install pandoc
brew install basictex
brew install imagemagick
```
Eisvogel Template:
https://github.com/Wandmalfarbe/pandoc-latex-template

## Check Image DPI
```bash
identify -format "%w x %h %x x %y" image.png
```
