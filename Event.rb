# Copyright 2013 Glen Newton glen.newton@gmail.com
# Apache2 license
#

class Event
  attr_accessor :doc_id, :foo, :doc_source, :sentence_offset, :event_type, :negated, :speculated, :agent_is_event, :agent_event_type, :agent, :agent_entity_term, :agent_species, :agent_event_target, :agent_event_target_species, :t_is_event, :target_event_type, :target_event_agent, :target_event_agent_entity_term, :target_event_agent_species, :target, :target_entity_term, :target_species

    def initialize(rs)
        @agent = rs.getObject("c_c_entity_id")
        @agent_entity_term = rs.getObject("c_c_entity_term")
        @agent_event_target = rs.getObject("c_t_entity_id")
        @agent_event_target_species = rs.getObject("c_t_entity_species")
        @agent_event_type = rs.getObject("c_type")
        @agent_is_event = rs.getObject("c_is_event")
        @agent_species = rs.getObject("c_c_entity_species")
        @doc_id = rs.getString("doc_id")
        @doc_source = rs.getString("doc_source")
        @event_type = rs.getObject("type")
        @negated = rs.getObject("negated")
        @sentence_offset = rs.getObject("sentence_offset")
        @speculated = rs.getObject("speculated")
        @t_is_event = rs.getObject("t_is_event")
        @target = rs.getObject("t_t_entity_id")
        @target_entity_term = rs.getObject("t_t_entity_term")
        @target_event_agent = rs.getObject("t_c_entity_id")
        @target_event_agent_entity_term = rs.getObject("t_c_entity_term")
        @target_event_agent_species = rs.getObject("t_c_entity_species")
        @target_event_type = rs.getObject("t_type")
        @target_species = rs.getObject("t_t_entity_species")
    end

    def printAll()
        puts "agent_entity_term=" + @agent_entity_term + "\t c_c_entity_term"
        puts "agent=" + @agent + "\t c_c_entity_id"
        if (agent_event_target != nil)
                puts "@agent_event_target=" + @agent_event_target + "\t c_t_entity_id"
        end     
        if (agent_event_target_species != nil)
                puts "@agent_event_target_species=" + @agent_event_target_species + "\t c_t_entity_species"
        end
        if (agent_event_type != nil)
                puts "@agent_event_type=" + @agent_event_type + "\t c_type"
        end
        puts "agent_is_event=" + @agent_is_event + "\t c_is_event"
        puts "agent_species=" + @agent_species + "\t c_c_entity_species"
        puts "doc_id=" + @doc_id + "\t doc_id" 
        puts "doc_source=" + @doc_source + "\t doc_source"
        puts "event_type=" + @event_type + "\t type"
        puts "negated=" + @negated + "\t negated"
        puts "sentence_offset=" + @sentence_offset + "\t sentence_offset"
        puts "speculated=" + @speculated + "\t speculated"
        puts "t_is_event=" + @t_is_event + "\t t_is_event"
        puts "target=" + @target + "\t t_t_entity_id"
        puts "target_entity_term=" + @target_entity_term + "\t t_t_entity_term"
        puts "target_event_agent=" + @target_event_agent + "\t t_c_entity_id"
        puts "target_event_agent_entity_term=" + @target_event_agent_entity_term + "\t t_c_entity_term"
        puts "target_event_agent_species=" + @target_event_agent_species + "\t t_c_entity_species"
        puts "target_event_type=" + @target_event_type + "\t t_type"
        puts "target_species=" + @target_species + "\t t_t_entity_species"
    end     

end
