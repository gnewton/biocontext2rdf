# Copyright 2013 Glen Newton glen.newton@gmail.com
# Apache2 license
# 

require 'rubygems'
require 'java'
require 'json'
require 'dbi'
require 'jdbc/mysql'
require 'rdf'
require 'digest/md5'

include RDF

java_import java.security.MessageDigest


require 'Event'

$BIO2RDF_URI= 'http://bio2rdf.org/'
$RDF="rdf"

$nameSpace = { 
  "bio2rdf" => $BIO2RDF_URI,
  "dc" => "http://purl.org/dc/terms/",
  "owl" => "http://www.w3.org/2002/07/owl#",
  $RDF => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  "rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
  "sio" => "http://semanticscience.org/resource/",
  "xsd" => "http://www.w3.org/2001/XMLSchema#",
  # valid dataset namespaces
  'go' => 'http://bio2rdf.org/go:', 
  'biocontext' => 'http://bio2rdf.org/biocontext:',
  'biocontext_vocabulary' => 'http://bio2rdf.org/biocontex_vocabulary:',
  'biocontext_resource' => 'http://bio2rdf.org/biocontex_resource:',

  'gene' => 'http://bio2rdf.org/gene:', 

  'pubmed' => 'http://bio2rdf.org/pubmed:', 
  'pmc' => 'http://bio2rdf.org/pmc:', 

  'taxon' => 'http://bio2rdf.org/taxon:'
}



def Quad(subject_uri, predicate_uri, object_uri,  graph_uri = nil)
  if  graph_uri == nil
    graph_uri = ""
  else
    graph_uri = "<".concat(graph_uri).concat(">")
  end
  return "<#{subject_uri}> <#{predicate_uri}> <#{object_uri}> #{graph_uri} ."
end



def cn(a,b,c,d,e,f, g,h,i)
  if a.nil? or b.nil? or c.nil? or d.nil? or e.nil? or f.nil? or g.nil? or h.nil? or i.nil?
    $stderr.puts "a=[#{a}] b=[#{b}] c=[#{c}] d=[#{d}] e=[#{e}] f=[#{f}] g=[#{g}] h=[#{h}] i=[#{i}]"
  end
end



def QQuad(line_number, row_number, asubject, apredicate, aobject, graph = nil)
  subject_ns, subject = asubject.split(/:/)
  predicate_ns, predicate = apredicate.split(/:/)
  object_ns, object = aobject.split(/:/)

  cn($nameSpace[subject_ns], subject_ns, subject, $nameSpace[predicate_ns],predicate_ns, predicate, $nameSpace[object_ns], object_ns, object)

  return Quad($nameSpace[subject_ns] + subject, 
              $nameSpace[predicate_ns] + predicate, 
              $nameSpace[object_ns] + object)
end



def QuadLiteral(subject, predicate, literal, lang = nil, graph = nil) 
  if lang.nil?
    lang = ""
  else
    lang = "@"+lang
  end

  if graph.nil?
    graph=""
  else
    graph = "<" + graph + ">"
  end
  return "<#{subject}> <#{predicate}> \"#{literal}\" #{lang} #{graph} ."
end



def QQuadL(line_number, row_number, asubject, apredicate, aliteral, lang = nil, graph = nil) 
  subject_ns, subject = asubject.split(/:/)
  predicate_ns, predicate = apredicate.split(/:/)
  return QuadLiteral($nameSpace[subject_ns] +subject, 
              $nameSpace[predicate_ns]+predicate, 
              aliteral, lang, graph)
end

$DEFAULT="__default"

file = File.open("biocontext_mapping.json", "rb")
jsonText = file.read
mappings = JSON.parse(jsonText)

Java::com.mysql.jdbc.Driver
userurl = "jdbc:mysql://localhost/events"
connSelect = java.sql.DriverManager.get_connection(userurl, "mysql-userid", "mysql-password")
stmtSelect = connSelect.create_statement
stmtSelect.setFetchSize(java::lang::Integer::MIN_VALUE)



def md5(str)
  return Digest::MD5.hexdigest(str)
end     



def printRdf(sns,s,pns,p,ons,o)
  subject   = RDF::URI.new(sns + ":" + s)
  predicate = RDF::URI.new(pns + ":" + p)
  object    = RDF::URI.new(ons + ":" + o)
  puts RDF::Statement.new(subject, predicate, object)

end



def biordf(str)
  return $nameSpace["bio2rdf"] + str
end



def write_event_triples(line_number, row_number, event_id, doc_source, doc_id, agent_event_id =nil)
  if event_id != nil && doc_source != nil && doc_id != nil
    puts QQuad(line_number, row_number, "biocontext_resource:".concat(event_id), $RDF + ":" + "type", "biocontext_vocabulary:Event");
  end     

  if doc_source.downcase == "medline"
    puts QQuad(line_number, row_number, "biocontext_resource:"+event_id, "sio:SIO_000253", "pubmed:"+doc_id);
  else if doc_source.downcase == "pmc"
         puts QQuad(line_number, row_number, "biocontext_resource:"+event_id, "sio:SIO_000253", "pmc:"+doc_id);
       else
         puts QQuad(line_number, row_number, "biocontext_resource:" + event_id, "sio:SIO_000253", doc_source+":"+doc_id);
       end
  end
  
  if agent_event_id != nil
    puts QQuad(line_number, row_number, "biocontext_resource:"+event_id, "biocontext_vocabulary:agent", "biocontext_resource:"+agent_event_id);
  end
  
end     



def write_event_type_triple(mappings, line_count, row_count, subject, predicate, objectt, doc_source, doc_id)
  event_type_map = mappings["event_type_triple"]
  if event_type_map.has_key?(predicate)
    target_event_map = event_type_map[predicate]
    if target_event_map.has_key?(objectt)
      puts QQuad(line_count, row_count, "biocontext_resource:".concat(subject), "rdf:type", target_event_map[objectt])
    end
  end
end     



def write_agent_triples(line_number, row_number, event_id, agent, agent_entity_term, agent_species)
  if ! agent.nil? && agent != "0"
    puts QQuad(line_number, row_number, "biocontext_resource:"+ event_id, "biocontext_vocabulary:agent", "gene:"+ agent);
  else
    if agent == "0" && !agent_entity_term.nil?
      agent_id = md5(row_number.to_s + event_id + agent_entity_term);
      puts QQuad(line_number,  row_number, "biocontext_resource:"+ event_id, "biocontext_vocabulary:agent", "biocontext_resource:"+ agent_id);
      puts QQuadL(line_number, row_number, "biocontext_resource:"+agent_id, "rdfs:label", agent_entity_term);
    end
    
    if !agent_species.nil? && agent_species != "0"
      #add triple about agent species
      puts QQuad(line_number, row_number, "biocontext_resource:"+ event_id, "biocontext_vocabulary:species", "taxon:"+ agent_species);
    end
  end
end



def write_event_target_event_triples(line_number, row_number, event_id, target_event_id, doc_source, doc_id)
  puts QQuad(line_number, row_number, "biocontext_resource:"+event_id, "biocontext_vocabulary:target", "biocontext_resource:"+target_event_id)
  puts QQuad(line_number, row_number, "biocontext_resource:"+target_event_id, "rdf:type", "biocontext_vocabulary:Event")
	
  if doc_source.downcase == 'medline'
    puts QQuad(line_number, row_number, "biocontext_resource:"+target_event_id, "sio:SIO_000253", "pubmed:"+doc_id)
  else
    if doc_source.downcase == 'pmc'
      puts QQuad(line_number, row_number, "biocontext_resource:"+target_event_id, "sio:SIO_000253", "pmc:"+doc_id)
    end
  end

end




def write_agent_event_type_triple(mappings, line_count, row_count, agent_event_id, agent_event_type)
  event_type_map = mappings["agent_event_type_triple"]
  if event_type_map.has_key?(agent_event_type)
    puts QQuad(line_count, row_count, "biocontext_resource:".concat(agent_event_id), "rdf:type", event_type_map[agent_event_type])
    end
end



def write_target_triples(line_number, row_number, event_id, target, target_entity_term, target_species)
  if target != "0"
    puts QQuad(line_number, row_number, "biocontext_resource:"+ event_id, "biocontext_vocabulary:target", "gene:"+ target)
  else
    if target == "0"
      target_id = md5(line_number.to_s + event_id+target_entity_term)
      puts QQuad(line_number, row_number, "biocontext_resource:"+event_id, "biocontext_vocabulary:target", "biocontext_resource:"+target_id)
      puts QQuadL(line_number, row_number, "biocontext_resource:"+target_id, "rdfs:label", target_entity_term);
    end
  end
  if target_species != nil && target_species != "0"
    #add triple about target species
    puts QQuad(line_number, row_number, "biocontext_resource:"+event_id, "biocontext_vocabulary:species", "taxon:"+target_species)
    end
end



################################################################################################
####### main ###################################################################################
################################################################################################

selectquery = "select * from data_events_export where type is not null and t_type is not null and t_t_entity_id is not null and c_c_entity_id is not null"

# Execute the query
rsS = stmtSelect.execute_query("set read_buffer_size=16777216*8;")
rsS = stmtSelect.execute_query(selectquery)

row_count = 0
line_count = 0
while (rsS.next) do
  row_count+= 1
  line_count+= 1
  ev = Event.new(rsS)  

  event_id = md5(row_count.to_s() + ev.doc_id + ev.sentence_offset + ev.event_type + ev.agent + ev.target)
  write_event_triples(line_count, row_count, event_id, ev.doc_source, ev.doc_id)
  write_event_type_triple(mappings, line_count, row_count, event_id, ev.event_type, ev.target_event_type, ev.doc_source, ev.doc_id)

  if ev.agent_is_event == "0"
	write_agent_triples(line_count, row_count, event_id, ev.agent, ev.agent_entity_term, ev.agent_species)							
  elsif ev.agent_is_event == "1"
	if ev.agent_event_target != nil && ev.agent_event_target != "0"
      agent_event_id = md5(row_count.to_s() + ev.doc_id.to_s() + ev.sentence_offset + ev.event_type + ev.agent_event_type + ev.agent + ev.agent_event_target)
      write_event_triples(line_count, row_count, event_id, ev.doc_source, ev.doc_id)
      write_agent_event_type_triple(mappings, line_count, row_count, agent_event_id, ev.agent_event_type)	
      write_agent_triples(line_count, row_count, agent_event_id, ev.agent, ev.agent_entity_term, ev.agent_species)
      write_agent_event_type_triple(mappings, line_count, row_count, agent_event_id, ev.agent_event_target)
    end#target event known     
  end #agent is event

  #if t_is_event = 0 then target is an entity; if 1 then target is event
  if ev.t_is_event == "0"
	#add triple about target
	write_target_triples(line_count, row_count, event_id, ev.target, ev.target_entity_term, ev.target_species)
  elsif 
    ev.t_is_event == "1"
    #instantiate target event and add type triple
    if ev.target_event_agent != nil
      target_event_id = md5(row_count.to_s() + ev.doc_id + ev.sentence_offset + ev.event_type + ev.target_event_type + ev.target_event_agent + ev.target)

      write_event_target_event_triples(line_count, row_count, event_id, target_event_id, ev.doc_source, ev.doc_id)

      write_agent_event_type_triple(mappings, line_count, row_count, target_event_id, ev.target_event_type)

      write_agent_triples(line_count, row_count, target_event_id, ev.target_event_agent, ev.target_event_agent_entity_term, ev.target_event_agent_species)

      write_target_triples(line_count, row_count, target_event_id, ev.target, ev.target_entity_term, ev.target_species)
    end
  end
end
# Close off the connection
stmtSelect.close
connSelect.close










