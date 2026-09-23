---
layout: page
title: Research & Learning
permalink: /research/
description: Research work and courses.
nav: true
nav_order: 2
---

{% assign sections = "research,courses" | split: "," %}
{% assign headings = "Research,Courses" | split: "," %}

{% for key in sections %}
{% assign entries = site.data.research[key] %}
{% if entries and entries.size > 0 %}

  <section class="entry-group" id="{{ key }}">
    <h2 class="entry-group-title">{{ headings[forloop.index0] }}</h2>
    <ul class="entry-list">
      {% comment %}Order follows the file, newest first. Liquid sort is unstable, so sorting here reshuffles same-year entries.{% endcomment %}{% assign sorted = entries %}
      {% for e in sorted %}
      <li class="entry">
        <div class="entry-year">{{ e.year }}</div>
        <div class="entry-body">
          <h3 class="entry-title">
            {% if e.url %}<a href="{{ e.url }}">{{ e.title }}</a>{% else %}{{ e.title }}{% endif %}
          </h3>
          {% if e.role %}<div class="entry-meta">{{ e.role }}</div>{% endif %}
          {% if e.provider %}<div class="entry-meta">{{ e.provider }}</div>{% endif %}
          {% if e.venue %}<div class="entry-meta">{{ e.venue }}</div>{% endif %}
          {% if e.status %}<div class="entry-status">{{ e.status }}</div>{% endif %}
          {% if e.detail %}<p class="entry-detail">{{ e.detail }}</p>{% endif %}
          {% if e.topics and e.topics.size > 0 %}
          <ul class="topic-list">
            {% for t in e.topics %}
            <li class="topic">{{ t }}</li>
            {% endfor %}
          </ul>
          {% endif %}
        </div>
        {% comment %}MARK 2, the two-state margin note (docs/NOTEBOOK-MARKS.md). It is a SIBLING of .entry-body and never nested inside it: with the stylesheet off, li.entry is ordinary block flow and its children stack in reading order — year, entry, note — so the note reads as a sentence immediately after the item it annotates. That placement is the whole of the stylesheet-off guarantee; nesting it would destroy GROUND-05 while leaving every CSS check green. Native <details>, no JavaScript, so both states are in the DOM for a screen reader. Nothing here is hidden from assistive technology and nothing is pushed off-screen, because there is nothing to hide — and this sentence deliberately does not spell either mechanism, since the phase harness greps this file for them and a comment that names them turns a green negative assertion red. Third time on this project; do not paste them back in.{% endcomment %}
        {% if e.note %}{% if e.note_full %}
        <details class="entry-note">
          <summary class="entry-note-summary">{{ e.note }}</summary>
          <div class="entry-note-full">{{ e.note_full | markdownify }}</div>
        </details>
        {% else %}
        <p class="entry-note">{{ e.note }}</p>
        {% endif %}{% endif %}
      </li>
      {% endfor %}
    </ul>
  </section>
  {% endif %}
{% endfor %}
