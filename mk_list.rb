#! /usr/bin/env ruby
# Parse vocabulary definition in CSV to generate Context+Vocabulary in JSON-LD or Turtle

require 'getoptlong'
require 'csv'
require 'json'
require 'erubis'

class List
  JSON_STATE = JSON::State.new(
    :indent       => "  ",
    :space        => " ",
    :space_before => "",
    :object_nl    => "\n",
    :array_nl     => "\n"
  )

  TITLE = "OpenActive Activity List".freeze
  DESCRIPTION = %(This document describes the OpenActive standard activity list.).freeze
  attr_accessor :terms, :date, :commit

  def initialize
    path = File.expand_path("../activity-list.csv", __FILE__)

#    git_info = %x{git log -1 #{path}}.split("\n")
#    @commit = "https://github.com/openactive/activity-list/commit/" + git_info[0].split.last

#    @date = Date.parse(git_info[2].split(":",2).last).strftime("%Y-%m-%d")

    #All Terms, id=>description    
    @terms = {}
    #Label -> ID
    @index = {}  
    #TT ID => Array of Child Labels  
    @top_terms={}
    
#CSV structure:
#id of term
#broader term label
#narrower term label
#synonyms (comma separated)
#descriptions


    CSV.foreach(path, {headers: true}) do |row|
        prefLabel = row[2].nil? ? row[1] : row[2]
        @index[prefLabel] = row["ID"]
        term = {
            "id": "http://openactive.io/activity-list/##{row["ID"]}",
            "type": "skos:Concept",
            "prefLabel": prefLabel,
        }        
        term["skos:definition"] = row["DESCRIPTION"] if row["DESCRIPTION"]
        if row[2].nil?
            term["topConceptOf"] = "http://openactive.io/activity-list/"
            @top_terms[ row["ID"] ] = []
        else
            term["broader"] = "http://openactive.io/activity-list/##{@index[row[1]]}"   
            #TODO narrower
            @top_terms[ @index[row[1]] ] << row["ID"]
        end
        if !row["SYNONYMS"].nil?
            labels = CSV.parse_line( row["SYNONYMS"] )
            labels.map!{ |l| l.lstrip.rstrip }
            term["altLabel"] = labels
        end
        
        @terms[ row["ID"] ] = term
    end
    
  end

  def to_jsonld
    list = {
        "@context": "https://www.openactive.io/ns/oa.jsonld",
        "@id": "http://openactive.io/activity-list/",
        "title": TITLE,
        "description": DESCRIPTION,
        "type": "skos:ConceptScheme", 
        "license": "https://creativecommons.org/licenses/by/4.0/",
        "concepts": terms.values
    }
    
    list.to_json(JSON_STATE)
  end

  def to_html
    json = JSON.parse(to_jsonld)
    eruby = Erubis::Eruby.new(File.read("template.html"))
    eruby.result(list: json, terms: @terms, index: @index, top_terms: @top_terms)
  end

  def to_ttl
    output = []
    {
        "oa": "http://openactive.org/ns#",
        "dc": "http://purl.org/dc/terms/",
        "owl": "http://www.w3.org/2002/07/owl#",
        "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdfa": "http://www.w3.org/ns/rdfa#",
        "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
        "schema": "http://schema.org/",
        "skos": "http://www.w3.org/2004/02/skos/core#",
        "xsd": "http://www.w3.org/2001/XMLSchema#",
    }.each do |prefix, uri|
        output << "@prefix #{prefix}: <#{uri}> ."
    end
    uri = "http://openactive.io/activity-list/"
    output << "<#{uri}> a skos:ConceptScheme ."
    output << "<#{uri}> dc:title '#{TITLE}' ."
    output << "<#{uri}> dc:description '#{DESCRIPTION}' ."
    output << "<#{uri}> dc:license <https://creativecommons.org/licenses/by/4.0/> ."
    output << ""        
    @terms.values.each do |term|
        uri = term[:id]
        output << "<#{uri}> a skos:Concept ."
        output << "<#{uri}> skos:prefLabel '#{term[:prefLabel]}' ."
        output << "<#{uri}> skos:definition \"#{term['skos:definition']}\" . " unless term['skos:definition'].nil?
        output << "<#{uri}> skos:broader <#{term['broader']}> . " unless term['broader'].nil?
        output << "<#{uri}> skos:topConceptOf <#{term["topConceptOf"]}> . " unless term['topConceptOf'].nil?
        term["altLabel"].each do |label|
            output << "<#{uri}> skos:altLabel '#{label}' ."
        end if term["altLabel"]
        output << ""
    end
    
    output.join("\n")
  end

end

options = {
  output: $stdout
}

OPT_ARGS = [
  ["--format", "-f",  GetoptLong::REQUIRED_ARGUMENT,"Output format, default #{options[:format].inspect}"],
  ["--output", "-o",  GetoptLong::REQUIRED_ARGUMENT,"Output to the specified file path"],
  ["--quiet",         GetoptLong::NO_ARGUMENT,      "Supress most output other than progress indicators"],
  ["--help", "-?",    GetoptLong::NO_ARGUMENT,      "This message"]
]
def usage
  STDERR.puts %{Usage: #{$0} [options] URL ...}
  width = OPT_ARGS.map do |o|
    l = o.first.length
    l += o[1].length + 2 if o[1].is_a?(String)
    l
  end.max
  OPT_ARGS.each do |o|
    s = "  %-*s  " % [width, (o[1].is_a?(String) ? "#{o[0,2].join(', ')}" : o[0])]
    s += o.last
    STDERR.puts s
  end
  exit(1)
end

opts = GetoptLong.new(*OPT_ARGS.map {|o| o[0..-2]})

opts.each do |opt, arg|
  case opt
  when '--format'       then options[:format] = arg.to_sym
  when '--output'       then options[:output] = File.open(arg, "w")
  when '--quiet'        then options[:quiet] = true
  when '--help'         then usage
  end
end

list = List.new
case options[:format]
when :jsonld  then options[:output].puts(list.to_jsonld)
when :ttl     then options[:output].puts(list.to_ttl)
when :html    then options[:output].puts(list.to_html)
else
  %w(jsonld ttl html).each do |format|
    File.open(format == 'html' ? 'index.html' : "activity-list.#{format}", "w") do |output|
      output.puts(list.send("to_#{format}".to_sym))
    end
  end
end
