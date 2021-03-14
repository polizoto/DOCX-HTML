# DOCX-HTML
Create Accessible HTML Files From DOCX

## Requirements
- [Git for Windows](https://git-scm.com/download/win) 
- [Pandoc](https://pandoc.org/installing.html)
- [NuHTML Checker for PC](https://github.com/validator/validator/releases/download/20.6.30/vnu.windows.zip) OR [NuHTML Checker for macOS](https://github.com/validator/validator/releases/download/20.6.30/vnu.jar_20.6.30.zip)
- [CSS Stylesheet](https://github.com/polizoto/DOCX-HTML/blob/main/stylesheets/standard.css)
- [Tasklist.exe](https://www.computerhope.com/download/winxp.htm) (PC only)

## Setup
1. Download the DOCX-HTML.sh script to your macOS or PC
2. Place the script in an easy-to-locate folder (`C:\scripts\`)
3. Create a "stylesheets" folder in your `C:\` drive (PC) or in your Home directory `~/` (Mac); Name your default stylesheet "standard.css"
4. Download and unpack the NuHTML Windows Zip folder to your `C:\` drive (PC) or place the the vnu.jar file in your Home directory `~/` (Mac)
5. Place Tasklist.exe in the `C:\scripts\` folder (PC only)

## Features
- Table of contents (Headings 1-3)
- Language switches are automatically added (`lang` attribute). Up to nine secondary languages
- table accessibility markup is automatically added (e.g., `colspan`, `rowspan`, `scope` attributes) when MS Word Tags are used
- math output options (mathjax, mathml, webtex, SVG)
- hyperlinks for footnotes (automatically added with the -f option)
- `<aside>` element for lines numbers (poetry)
- `<aside>` element for secondary text and footnote regions
- `<details>` element for extended descriptions
- receive HTML accessibility warnings and errors in the terminal (NuHTML checker)
- edit HTML directly with VIM in the terminal (when using the -e option)

## Overview
DOCX-HTML.sh is a bash script that converts DOCX files to HTML (web) format. The script performs numerous find and replace operations on an HTML file to ensure that the file is fully accessible to students using assistive technologies. 

This ReadMe has two parts: 1) how to structure your MS Word document for use with the DOCX-HTML.sh script and 2) how to run the DOCX-HTML.sh script.

## Getting Started
Before using the DOCX-HTML.sh script, it is important to make sure that the MS Word document you are converting contains the following features:

- Heading structure
- Alternative text for images
- Page numbers  are styled as Heading 6 (for easier navigation)

In addition to these elements, there are some HTML accessibility features that are not added by the script unless you use “MS Word tags” in your document. These “tags” are detected by the script and replaced with the appropriate HTML elements and attributes. 

### MS Word Tags

For a complete list of the tags that are recognized by the DOCX-HTML.sh script, see the [MS Word Tags document](https://www.dropbox.com/s/lhogh996v2itfzq/MS%20Word%20Tags-DOCX-HTML.docx?dl=0). This document explains how each of the tags should be used in your MS Word document.

We will give a few examples of the most common tags below:

#### Secondary Text

When there is text in a document that is not essential to the main content (e.g., a sidebar), this is “secondary text”. On the line above secondary text, enter the following tag: 

`Secondary Text Begin:`

And on the line below secondary text, enter:

`Secondary Text End.`

#### Footnote Text
If there are footnotes in your document, make sure that these have superscript formatting. For the footnote references (on the bottom of each page OR at the end of the document) use the following tag above the footnote text region:

`Footnote Begin:`

And on the line below footnote text region, enter:

`Footnote End.`

#### Foreign Languages
The DOCX-HTML.sh script automatically makes English the default language for the HTML file. If there are other languages in your MS Word document, these languages need to be marked with language tags. 

Insert the following tag before the foreign language text:

`###1`

And enter the following tag after the foreign language text:

`%%%`

**Note:** These tags should be used in-line with text in your document. If there is more than one foreign language, use `###2` and `###3` before the second and  third foreign languages, respectively, and use the same ending tag (`%%%`) at the end of these passages. The DOCX-HTML.sh script can process up to nine foreign languages in your MS Word document.

#### Figure Captions
A figure caption is text that identifies an image. It is text that normally appears immediately before or after the image which help readers understand what the image is about. 

Write the following tag before figure caption:

`Figcaption Begin:`

And on the line below the figure caption text, enter:

`Figcaption End`

#### Extended Descriptions
If there are complex images in the document, write an extended description. Keep the alt text for this image short (What does it show?) and write “description to follow.” at the end of the alt text. 

Write your extended description and then add the following tag above the description:

`Description Begin:`

And on the line below the extended description, write:

`Description End.`

**Note:** Extended descriptions must come immediately after the image in the MS Word document for the DOCX-HTML.sh script to process the Description Begin: … Description End. tags successfully.

#### Table Captions
A table caption is text that identifies a table. It is text that normally appears immediately before or after the table. 

Write the following tag immediately before table captions in your MS Word document:

`Caption Begin:`

And on the line below the table caption, write:

`Caption End.`

**Note:** Table captions must come immediately before the table in the MS Word document for the DOCX-HTML.sh script to process the Caption Begin: … Caption End. tags successfully.

### MS Word Tables
#### General Information
There are two types of tables that you may encounter in your MS Word document: *simple* tables and *complex* tables.

A simple table is a table that has no merged cells. A complex table has merged cells and there is a different number of cells in each row of the table.

When you are working with simple tables, make sure that the “Header Row” checkbox is checked in the Table Style Options group of the Table Design Tab, when you insert your cursor in that table.

If it is a complex table and there are multiple column headers for cells in the table, make sure that the “Header Row” checkbox is unchecked when you insert your cursor in that table. See the example of [a complex table](https://www.dropbox.com/s/z87xgy61f6aa4uk/Complex%20Table%20-%20No%20Tags.docx?dl=0).

Note that columns 2-4 have children columns. When using the DOCX-HTML.sh script, this table should *not* have the “Header Row” marked.

#### Tags for MS Word Tables
If your table is simple, there usually isn’t anything else that you have to do than make sure that the “Header Row” is marked.

If your table is complex, however, you will need to add tags to the table to ensure that the table will be processed correctly by the DOC-HTML.sh script. Otherwise, you will need to do heavy editing of the HTML document in an HTML editor (e.g., Dreamweaver), which can significantly increase the amount of time you spend converting the document. 

For an extended explanation of how to use MS Word tags in tables for use with the DOCX-HTML.sh script, see the [MS Word Tags document](https://www.dropbox.com/s/lhogh996v2itfzq/MS%20Word%20Tags-DOCX-HTML.docx?dl=0). 

We will give a few examples of common MS Word tags for tables below:

##### Column Headers
When a cell in the first row of your table has multiple columns underneath it, we call this cell a “parent column header”. The cell is the parent of “children columns”. With this type of table, you will need to add tags so that the DOCX-HTML.sh script can determine the number of parent column headers and children columns correctly. 

See the example of a [complex table - with tags](https://www.dropbox.com/s/ue8z3krj0qtkk8z/Complex%20Table%20-%20With%20Tags.docx?dl=0)

In the first cell of this table, the tag begins with the number of children columns for this cell. There is only one column beneath this cell so we insert the number 1. Next we indicate that this cell is a column header by using `$`. Next we use the `@` symbol followed by the number of children columns of each parent column header (`122`) for the entire table. 

With the rest of the cells in the first row of this table, we again use tags to indicate the number of children columns underneath the cells (`2`) and to indicate that these cells are column header cells (`$`)

In the second row of the table, we also use the $ tag to indicate that these cells are column headers. We do not use a number next to them because they are not parent column headers.

For more information about complex tables with parent column headers, see the [MS Word Tags document](https://www.dropbox.com/s/lhogh996v2itfzq/MS%20Word%20Tags-DOCX-HTML.docx?dl=0). 

##### Row Headers

