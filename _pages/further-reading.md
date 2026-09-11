---
layout: page
title: Further Reading
permalink: /further-reading/
description: Papers and books I have read, with notes.
nav: true
nav_order: 3
---

{% assign sections = "papers,books" | split: "," %}
{% assign headings = "Papers,Books" | split: "," %}

{% assign paper_count = site.data.further_reading.papers | size %}
{% assign book_count = site.data.further_reading.books | size %}
{% if paper_count == 0 and book_count == 0 %}

  <p class="entry-detail">Notes on what I am reading are going up here shortly.</p>
{% endif %}

{% for key in sections %}
{% assign entries = site.data.further_reading[key] %}
{% if entries and entries.size > 0 %}

  <section class="entry-group" id="{{ key }}">
    <h2 class="entry-group-title">{{ headings[forloop.index0] }}</h2>
    <ul class="entry-list">
      {% comment %}Order follows the file, newest first. Liquid sort is unstable, so sorting here reshuffles same-year entries.{% endcomment %}
      {% for e in entries %}
      <li class="entry">
        <div class="entry-year">{{ e.year }}</div>
        <div class="entry-body">
          <h3 class="entry-title">
            {% if e.url %}<a href="{{ e.url }}">{{ e.title }}</a>{% else %}{{ e.title }}{% endif %}
          </h3>
          {% if e.author %}<div class="entry-meta">{{ e.author }}</div>{% endif %}
          {% if e.venue %}<div class="entry-meta">{{ e.venue }}</div>{% endif %}
          {% if e.notes %}<div class="entry-notes">{{ e.notes | markdownify }}</div>{% endif %}
        </div>
      </li>
      {% endfor %}
    </ul>
  </section>
  {% endif %}
{% endfor %}
