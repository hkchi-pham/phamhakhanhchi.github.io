---
layout: page
permalink: /cv/
title: cv
nav: true
nav_order: 5
description: Full curriculum vitae.
---

{% assign cv_file = "/assets/pdf/cv.pdf" %}

<p class="cv-actions">
  <a class="btn btn-sm z-depth-0" href="{{ cv_file | relative_url }}" target="_blank" rel="noopener">
    <i class="fa-solid fa-download" aria-hidden="true"></i> Download PDF
  </a>
</p>

<object class="cv-embed" data="{{ cv_file | relative_url }}" type="application/pdf" width="100%" height="800">
  <p>
    Your browser cannot display PDFs inline.
    <a href="{{ cv_file | relative_url }}">Download the CV instead</a>.
  </p>
</object>

<!--
TODO — put your CV at assets/pdf/cv.pdf (that exact name) and delete
assets/pdf/example_pdf.pdf. Until then this page shows a broken embed.

To point at a different filename or an external URL, change `cv_file` above.
-->
