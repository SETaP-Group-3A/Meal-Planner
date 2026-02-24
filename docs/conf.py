# Configuration file for the Sphinx documentation builder.
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/config.html

project = 'Meal-Planner'
copyright = '2026, Oskar Wieczorek, WoodhouseA, badideainc, Aryaan3123, 7nnu, alexsadler12, icepawls'
author = 'Oskar Wieczorek, WoodhouseA, badideainc, Aryaan3123, 7nnu, alexsadler12, icepawls'
release = '1.0'

# -- General configuration ---
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.githubpages',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# -- Options for HTML output ---
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']

# -- Options for autodoc ---
autodoc_mock_imports = ['flutter', 'dart']
