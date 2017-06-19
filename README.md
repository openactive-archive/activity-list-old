# OpenActive Activity List

This repository holds the data and documentation for the OpenActive list of physical activities.

A Physical Activity is an exercise, sport or other form of bodily movement that involves physical effort. 
Physical activities include not just sports, but also a variety of forms of exercise and fitness classes. 
An Activity List defines a list of physical activities.

A standardised activity list, that provides unique identifiers, labels and descriptions for physical activities can:

* support integration of data published by multiple activity providers
* improve user experience across applications through use of a standard set of activity names and definitions
* enable better discovery and recommendation tools to enable participants to find more opportunities to be active

The list is publicaly available at [https://www.openactive.io/activity-list/](https://www.openactive.io/activity-list/).

Alternative formats of the list are available as

* [CSV](https://www.openactive.io/activity-list/activity-list.csv)
* [JSON-LD](https://www.openactive.io/activity-list/activity-list.jsonld)
* [Turtle](https://www.openactive.io/activity-list/activity-list.ttl)

## Dataset Documentation

The dataset is structured according to the [SKOS](https://www.w3.org/TR/skos-primer/) standard for publishing controlled vocabularies.

It consists of:

* a list of terms with an identifier (a URI) and a preferred label (`skos:prefLabel`)
* relationships between terms (`skos:broader` and `skos:narrower`)
* alternative labels (synonyms, `skos:altLabel`)

### Identifiers

Terms in the list have been assigned a UUID to generate a unique identifier. The URIs for each terms are [Patterned URIs](http://patterns.dataincubator.org/book/patterned-uris.html) 
that combine these UUIDs with a common prefix:

E.g. Fencing has been assigned a UUID of `92808e60-820c-4ee2-89ec-ea8d99d3f528`. It's URI is `http://openactive.io/activity-list/#92808e60-820c-4ee2-89ec-ea8d99d3f528`

### JSON-LD

The [JSON-LD version of the list](https://www.openactive.io/activity-list/activity-list.jsonld) provides a simple JSON version of the list that conforms to the [JSON-LD](https://www.w3.org/TR/json-ld/) specification.

### CSV

The [CSV version of the list](https://www.openactive.io/activity-list/activity-list.csv) provides a simple tabular CSV format for working with the activity list.

The columns of the CSV file are:

1. `ID` of the term being defined
2. Preferred Label of the broader term being defined
3. Preferred Label of the narrower term being defined
4. Synonyms for the term
5. Definition of the term

If a broader term is being defined then only columns 1, 2, 4, and 5 may be populated. If a narrower term is being defined then all columns are relevant.
The labels of the broader term is repeated on each row to make it easier to read and understand the structure of the list in a spreadsheet application. 

## Publication process

* Changes are made to the CSV file by the editors
* Updated CSV file is checked into the repository
* Ruby `ruby mk_list.rb` to generate the Turtle, JSON-LD and HTML+RDFa versions of the specification
* Commit and push to master which will trigger github pages to deploy the new version

Run `bundle` to install the `erubis` gem used to generate the HTML.

## Licence

The documentation and data in this repository is published under 
the [Creative Commons CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/) license.

The Ruby code and templates are placed into the public domain under the [Unlicense](http://unlicense.org/) waiver.


