+++
title = "Blogging with Zola: Overview"
date = 2025-02-06

[taxonomies]
series = ["zola"]
tags = ["all", "web"]
+++

## What, Why?
{{ link(label="Zola", link="https://www.getzola.org/") }} is a static site generator (SSG) that is fast, intuitive, and highly customisable.
This is Part 1 of the Zola {{ link(label="series", link="/series/zola", target="") }} where I share and explore how I make use of Zola to create my ideal blog. 
In this page, I'll share about the core concepts and designs Zola adopts that makes it fun to use.

### Markdown
Zola turns Markdown content into HTML pages that can be rendered on the web.
Markdown is lightweight and portable, hence content can easily be managed.
Being a text format, it can take advantage of Git's version control system.
I host my site's files on Github and set up Cloudflare Pages to automatically build and deploy the site when I push changes to the `main` branch.


### Templates
Zola stores Markdown files in the `content/` directory.
Each Markdown file needs to have a HTML template which Zola will use to render the Markdown content.
Zola looks for these templates in the `templates/` directory.

Zola provides variables to use in templates.
In this example, `page.content` refers to the HTML content produced by a Markdown file that uses this template to render its content.

1. Important: `safe` filter is required so the HTML (generated from Markdown) won't be escaped, and will be rendered properly.

```html
<!doctype html>
<html lang="en">
<body>
    {{ page.content | safe }}
</body>
</html>
```
`templates/page.html`


In Zola, frontmatter is required in Markdown files.
It uses TOML format and is defined between two `+++` lines at the top of the file.
The variables defined can be used by templates too.
For example, the tab title can be supplied using `page.title` which gives `Example`.

```md
+++
title = "Example"
date = 2025-01-01
template = "page.html"
+++

<!-- page.content -->
## Heading
Paragraph
```
`content/page.md`

### Path-based Rendering
Zola follows the directory structure when creating the website.
The `content/` directory is the root.
Pages can either be named directly or placed in a folder and be named `index.md`.
Examples of how different paths are rendered:
1. `content/index.md` -> `/`
2. `content/about.md` -> `/about`
3. `content/about/index.md` -> `/about`

#### Sections
Zola also has sections.
They are created by adding a `_index.md` file in the directory where a section is to be created.
A common use case for sections is to group pages together and display the pages it contains.
For example, a `blog` section may display the posts it contains.

#### Taxonomies
One caveat of sections is that it isn't easy to fetch pages in nested sections to be grouped together.
Hence, I took a different approach and decided to use `taxonomies` to organise my blog instead.
For my website, I use {{ link(label="series", link="/series", target="") }} and {{ link(label="tags", link="/tags", target="") }} 
taxonomies to categorise pages.


### Extensible Templates
Templates can be created such that common components such as headers and footers can be reused.
To achieve something like this, a base template `base.html` is created and `page.html` extends it.
In `base.html`, a block named `body` is created and in `page.html`, the block is filled with the page's content.
```html
<!doctype html>
<html lang="en">
<body>
    <header>
        ...
    </header>
    {% block body %}
    {% endblock body %}
</body>
</html>
```
`templates/base.html`

```html
{% extends "base.html" %}

{% block body %}
    {{ page.content | safe }}
{% endblock body %}
```
`templates/page.html`


#### Macros and Shortcodes
For components that need more flexibility to be inserted *anywhere* in templates/content, macros and shortcodes do the trick.
For example, a `<button>` with a nested `<a>` may be used quite often and a component could be created for it.

Macros and shortcodes have some differences:
1. Macros: to be used in HTML templates only.
2. Shortcodes: to be used in Markdown content only, but can call macros. Has to be defined in `templates/shortcodes`

A button macro and shortcode pair is shown below. The macro takes two parameters, `label` and `link`.
`link` is used for the `href` attribute and defaults to the root of the site.
The shortcode simply imports the macro and passes in the same parameters.

```html
{% macro button(label, link="/") %}
    <button><a href={{ link }}>{{ label }}</a></button>
{% endmacro button %}
```
`templates/macros.html`

```html
{% import "macros.html" as macros %}

{{ macros::button(label=label, link=link) }}
```
`templates/shortcodes/button.html`


Using the macro in a template is similar to using it in a shortcode as both are considered templates.
```html
{% import "macros.html" as macros %}

{{ macros::button(label="Home") }}
{{ macros::button(label="Blog", link="/blog") }}
```
`templates/nav.html`

In Markdown, the name of the shortcode is the file name sans the extension. Importing shortcodes isn't necessary.
```md
Visit my {{/* button(label="Blog", link="/blog") */}}
```


## Conclusion
This was a brief overview to what I *think* are the core concepts of Zola and the way I used them to create my blog.
In subsequent posts of the Zola {{ link(label="series", link="/series/zola", target="") }},
I dive deeper into how I used taxonomies, integrated TailwindCSS, and created various design components.
