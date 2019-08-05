prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2018.05.24'
,p_release=>'18.2.0.00.12'
,p_default_workspace_id=>20749515040658038
,p_default_application_id=>10500
,p_default_owner=>'SAMPLE'
);
end;
/
prompt --application/shared_components/plugins/dynamic_action/jk64_da_show_item_required
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(36152167620337362)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'JK64.DA_SHOW_ITEM_REQUIRED'
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
'begin',
'',
'  if apex_application.g_debug then',
'    apex_plugin_util.debug_dynamic_action',
'      (p_plugin         => p_plugin',
'      ,p_dynamic_action => p_dynamic_action);',
'  end if;',
'',
'  l_result.javascript_function := replace(q''[function() {',
'',
'    $.each(this.affectedElements, (i, element) => {',
'      apex.debug("show as required",$(element).attr("id"));',
'      var container = $(element).closest(".t-Form-fieldContainer");',
'      container.addClass("is-required");',
'      %SET_VALUE_REQUIRED%',
'      return true;',
'    })',
'',
'  }]''',
'  ,''%SET_VALUE_REQUIRED%'', case when l_set_value_required_yn=''Y'' then q''[$(element).prop("required",true);]'' end);',
'',
'  return l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'ITEM:JQUERY_SELECTOR:JAVASCRIPT_EXPRESSION:TRIGGERING_ELEMENT:REQUIRED'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'For APEX Universal Theme. Dynamic Action to show one or more items as Required. Put a condition on the parent Dynamic Action event to make it conditional.'
,p_version_identifier=>'0.1'
,p_about_url=>'https://jeffkemponoracle.com/2019/07/conditionally-required-floating-item/'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(36152300633340411)
,p_plugin_id=>wwv_flow_api.id(36152167620337362)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Set Value Required = Yes'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Select this to also set the Validation attribute "Value Required" to Yes. Default is to not change the attribute.'
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
