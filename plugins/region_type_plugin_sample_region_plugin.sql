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
,p_default_application_id=>10000
,p_default_owner=>'SAMPLE'
);
end;
/
prompt --application/shared_components/plugins/region_type/sample_region_plugin
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(37453481691408215)
,p_plugin_type=>'REGION TYPE'
,p_name=>'SAMPLE.REGION_PLUGIN'
,p_display_name=>'Sample Region Plugin'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- Sample Region Plugin v0.1 Aug 2019',
'',
'subtype plugin_attr is varchar2(32767);',
'',
'function render',
'    (p_region in apex_plugin.t_region',
'    ,p_plugin in apex_plugin.t_plugin',
'    ,p_is_printer_friendly in boolean',
'    ) return apex_plugin.t_region_render_result is',
'    ',
'    l_result apex_plugin.t_region_render_result;',
'',
'    -- Component settings',
'    --l_component_attribute  plugin_attr := p_plugin.attribute_01;',
'    --..',
'    --l_component_attribute  plugin_attr := p_plugin.attribute_15;',
'',
'    -- Plugin attributes',
'    --l_plugin_attribute     plugin_attr := p_region.attribute_01;',
'    --..',
'    --l_plugin_attribute     plugin_attr := p_region.attribute_25;',
'',
'    l_region_id varchar2(200);',
'    l_opt       varchar2(32767);',
'',
'begin',
'    -- debug information will be included',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_region',
'            (p_plugin => p_plugin',
'            ,p_region => p_region',
'            ,p_is_printer_friendly => p_is_printer_friendly);',
'    end if;',
'    ',
'    apex_javascript.add_library',
'        (p_name           => ''external-library.js''',
'        ,p_directory      => ''https://example.com/api/''',
'        ,p_skip_extension => true);',
'    ',
'    apex_javascript.add_library',
'        (p_name                  => ''local_javascript''',
'        ,p_directory             => p_plugin.file_prefix',
'        ,p_check_to_add_minified => true);',
'',
'    l_region_id := case',
'                   when p_region.static_id is not null',
'                   then p_region.static_id',
'                   else ''R''||p_region.id',
'                   end;',
'',
'    -- use nullif to convert default values to null; this reduces the footprint of the generated code',
'    l_opt := ''{''',
'      || apex_javascript.add_attribute(''regionId'', l_region_id)',
'      || case when p_region.init_javascript_code is not null then',
'         ''"initFn":function(){'' || p_region.init_javascript_code || ''},''',
'         end',
'      || apex_javascript.add_attribute(''noDataMessage'', p_region.no_data_found_message)',
'      || apex_javascript.add_attribute(''ajaxIdentifier'', apex_plugin.get_ajax_identifier)',
'      || apex_javascript.add_attribute(''ajaxItems'', apex_plugin_util.page_item_names_to_jquery(p_region.ajax_items_to_submit))',
'      || apex_javascript.add_attribute(''pluginFilePrefix'', p_plugin.file_prefix',
'         ,false,false)',
'      || ''}'';',
'  ',
'    apex_javascript.add_onload_code(p_code =>',
'      ''$("#'' || l_region_id || ''_container").widget('' || l_opt || '');''',
'      );',
'  ',
'    sys.htp.p(''<div id="'' || l_region_id || ''_container"></div>'');',
'    ',
'    return l_result;',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.message(dbms_utility.format_error_stack);',
'        apex_debug.message(dbms_utility.format_call_stack);',
'        raise;',
'end render;',
'',
'function ajax',
'    (p_region in apex_plugin.t_region',
'    ,p_plugin in apex_plugin.t_plugin',
'    ) return apex_plugin.t_region_ajax_result is',
'',
'    l_result apex_plugin.t_region_ajax_result;',
'',
'    -- Component settings',
'    --l_component_attribute  plugin_attr := p_plugin.attribute_01;',
'    --..',
'    --l_component_attribute  plugin_attr := p_plugin.attribute_15;',
'',
'    -- Plugin attributes',
'    --l_plugin_attribute     plugin_attr := p_region.attribute_01;',
'    --..',
'    --l_plugin_attribute     plugin_attr := p_region.attribute_25;',
'',
'    l_column_value_list     apex_plugin_util.t_column_value_list;',
'',
'begin',
'    if apex_application.g_debug then',
'        apex_plugin_util.debug_region',
'            (p_plugin => p_plugin',
'            ,p_region => p_region);',
'    end if;',
'',
'    l_column_value_list := apex_plugin_util.get_data',
'        (p_sql_statement  => p_region.source',
'        ,p_min_columns    => 2',
'        ,p_max_columns    => 2',
'        ,p_component_name => p_region.name',
'        --,p_max_rows       => 1000',
'        );',
'',
'    sys.owa_util.mime_header(''text/plain'', false);',
'    sys.htp.p(''Cache-Control: no-cache'');',
'    sys.htp.p(''Pragma: no-cache'');',
'    sys.owa_util.http_header_close;',
'    ',
'    sys.htp.p(''{"data":['');',
'',
'    for i in 1..l_column_value_list(1).count loop',
'',
'        sys.htp.p(',
'            apex_javascript.add_attribute(''colA'',l_column_value_list(1)(i))',
'          ||apex_javascript.add_attribute(''colB'',l_column_value_list(2)(i)',
'                                         ,false,false)',
'        );',
'    ',
'    end loop;',
'',
'    sys.htp.p('']}'');',
'',
'    apex_debug.message(''ajax finished'');',
'    return l_result;',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.message(dbms_utility.format_error_stack);',
'        apex_debug.message(dbms_utility.format_call_stack);',
'        sys.htp.p(''{"error":'' || apex_escape.js_literal(sqlerrm,''"'') || ''}'');',
'        return l_result;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'SOURCE_LOCATION:AJAX_ITEMS_TO_SUBMIT:NO_DATA_FOUND_MESSAGE:INIT_JAVASCRIPT_CODE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'Sample Region Plugin'
,p_version_identifier=>'0.1'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(37454087169408219)
,p_plugin_id=>wwv_flow_api.id(37453481691408215)
,p_name=>'INIT_JAVASCRIPT_CODE'
,p_is_required=>false
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(37453638686408218)
,p_plugin_id=>wwv_flow_api.id(37453481691408215)
,p_name=>'SOURCE_LOCATION'
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
