prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.03.31'
,p_release=>'19.1.0.00.15'
,p_default_workspace_id=>2300357799442810
,p_default_application_id=>300
,p_default_owner=>'SCBM'
);
end;
/
prompt --application/shared_components/plugins/dynamic_action/doe_da_show_item_required
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(6642480543261168)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'DOE.DA_SHOW_ITEM_REQUIRED'
,p_display_name=>'Show Item as Required'
,p_category=>'STYLE'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render',
'  (p_dynamic_action   in apex_plugin.t_dynamic_action',
'  ,p_plugin           in apex_plugin.t_plugin',
'  ) return apex_plugin.t_dynamic_action_render_result is',
'  l_result                apex_plugin.t_dynamic_action_render_result;',
'  l_set_value_required_yn p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'  l_show_optional_yn      p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'begin',
'  ',
'  if apex_application.g_debug then',
'    apex_plugin_util.debug_dynamic_action',
'      (p_plugin         => p_plugin',
'      ,p_dynamic_action => p_dynamic_action);',
'  end if;',
'  ',
'  if l_show_optional_yn=''Y'' then',
'',
'    l_result.javascript_function := replace(q''[function() {',
'',
'      $.each(this.affectedElements, (i, element) => {',
'        var itemId = $(element).attr("id");',
'        apex.debug("show as optional",itemId);',
'        $("#"+itemId+"_CONTAINER").removeClass("is-required");',
'        %SET_VALUE_REQUIRED%',
'        return true;',
'      })',
'',
'    }]''',
'    ,''%SET_VALUE_REQUIRED%'', case when l_set_value_required_yn=''Y'' then q''[$(element).prop("required",false);]'' end);',
'',
'  else',
'',
'    l_result.javascript_function := replace(q''[function() {',
'',
'      $.each(this.affectedElements, (i, element) => {',
'        var itemId = $(element).attr("id");',
'        apex.debug("show as required",itemId);',
'        $("#"+itemId+"_CONTAINER").addClass("is-required");',
'        %SET_VALUE_REQUIRED%',
'        return true;',
'      })',
'',
'    }]''',
'    ,''%SET_VALUE_REQUIRED%'', case when l_set_value_required_yn=''Y'' then q''[$(element).prop("required",true);]'' end);',
'',
'  end if;',
'  ',
'  return l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'ITEM:JQUERY_SELECTOR:JAVASCRIPT_EXPRESSION:TRIGGERING_ELEMENT:ONLOAD'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'For APEX Universal Theme. Dynamic Action to show one or more items as Required. Put a condition on the parent Dynamic Action event to make it conditional.'
,p_version_identifier=>'0.1'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6644037074365064)
,p_plugin_id=>wwv_flow_api.id(6642480543261168)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Set Value Required = True'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Select this to also set the Validation attribute "Value Required" to Yes. Default is to not change the attribute.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6644991117403634)
,p_plugin_id=>wwv_flow_api.id(6642480543261168)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Show as Optional'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Select this to do the opposite: show/set the item as Optional.'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
