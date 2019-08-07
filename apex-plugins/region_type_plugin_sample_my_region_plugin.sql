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
prompt --application/shared_components/plugins/region_type/sample_my_region_plugin
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(37453481691408215)
,p_plugin_type=>'REGION TYPE'
,p_name=>'SAMPLE.MY_REGION_PLUGIN'
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
'        (p_name                  => ''sample_region_plugin''',
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
'      ''$("#'' || l_region_id || ''_widget").myregionplugin('' || l_opt || '');''',
'      );',
'  ',
'    sys.htp.p(''<div id="'' || l_region_id || ''_widget"></div>'');',
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
,p_files_version=>4
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
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(37604534485698042)
,p_plugin_id=>wwv_flow_api.id(37453481691408215)
,p_name=>'loaded'
,p_display_name=>'loaded'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2F53616D706C6520526567696F6E20506C7567696E2076302E312041756720323031390D0A0D0A24282066756E6374696F6E2829207B0D0A2020242E77696467657428202273616D706C652E6D79726567696F6E706C7567696E222C207B0D0A202020';
wwv_flow_api.g_varchar2_table(2) := '200D0A202020202F2F2064656661756C74206F7074696F6E730D0A202020206F7074696F6E733A207B0D0A202020202020726567696F6E49643A22222C0D0A202020202020616A61784964656E7469666965723A22222C0D0A202020202020616A617849';
wwv_flow_api.g_varchar2_table(3) := '74656D733A22222C0D0A202020202020706C7567696E46696C655072656669783A22222C0D0A202020202020696E6974466E3A6E756C6C2C0D0A2020202020206E6F446174614D6573736167653A224E6F206461746120746F2073686F77222C0D0A0D0A';
wwv_flow_api.g_varchar2_table(4) := '2020202020202F2F2043616C6C6261636B73202D2074686573652063616E2062652063616C6C656420766961206A61766173637269707420696E20617065780D0A2020202020202F2F20652E672E2024282223726567696F6E69645F7769646765742229';
wwv_flow_api.g_varchar2_table(5) := '2E6D79726567696F6E706C7567696E28227265667265736822293B0D0A202020202020726566726573683A206E756C6C0D0A202020207D2C0D0A202020200D0A202020202F2F2054686520636F6E7374727563746F720D0A202020205F6372656174653A';
wwv_flow_api.g_varchar2_table(6) := '2066756E6374696F6E2829207B0D0A202020202020617065782E646562756728226D79726567696F6E706C7567696E2E5F63726561746520222B746869732E656C656D656E742E70726F70282269642229293B0D0A202020202020617065782E64656275';
wwv_flow_api.g_varchar2_table(7) := '6728226F7074696F6E733A20222B4A534F4E2E737472696E6769667928746869732E6F7074696F6E7329293B0D0A0D0A2020202020202F2F20696E697469616C69736174696F6E20636F646520676F657320686572650D0A202020202020746869732E66';
wwv_flow_api.g_varchar2_table(8) := '6F6F203D2027626172273B0D0A0D0A2020202020202F2F2062696E6420746865206170657872656672657368206576656E7420746F2072756E2074686520776964676574277320726566726573682066756E6374696F6E0D0A202020202020617065782E';
wwv_flow_api.g_varchar2_table(9) := '6A5175657279282223222B746869732E6F7074696F6E732E726567696F6E4964292E62696E6428226170657872656672657368222C66756E6374696F6E28297B0D0A202020202020202024282223222B5F746869732E6F7074696F6E732E726567696F6E';
wwv_flow_api.g_varchar2_table(10) := '49642B225F77696467657422292E6D79726567696F6E706C7567696E28227265667265736822293B0D0A2020202020207D293B0D0A0D0A2020202020202F2F2072756E20616E79204A61766153637269707420496E697469616C69736174696F6E20636F';
wwv_flow_api.g_varchar2_table(11) := '646520736574206F6E2074686520726567696F6E206174747269627574650D0A20202020202069662028746869732E6F7074696F6E732E696E6974466E29207B0D0A2020202020202020617065782E6465627567282272756E6E696E6720696E69745F6A';
wwv_flow_api.g_varchar2_table(12) := '6176617363726970745F636F64652E2E2E22293B0D0A20202020202020202F2F696E736964652074686520696E697428292066756E6374696F6E2077652077616E742022746869732220746F20726566657220746F20746869730D0A2020202020202020';
wwv_flow_api.g_varchar2_table(13) := '746869732E696E69743D746869732E6F7074696F6E732E696E6974466E3B0D0A2020202020202020746869732E696E697428293B0D0A2020202020207D0D0A2020202020200D0A2020202020202F2F20646F2074686520696E697469616C207265667265';
wwv_flow_api.g_varchar2_table(14) := '736820746F206765742074686520646174610D0A202020202020746869732E7265667265736828293B0D0A0D0A2020202020202F2F207472696767657220616E206576656E743B20612064796E616D696320616374696F6E2063616E20726573706F6E64';
wwv_flow_api.g_varchar2_table(15) := '20746F2074686973206576656E7420746F2061646420637573746F6D206265686176696F75720D0A2020202020202F2F204E6F74653A206F74686572206576656E74732063616E20626520747269676765726564207468652073616D6520776179207573';
wwv_flow_api.g_varchar2_table(16) := '696E6720636F6465206C696B6520746869732E0D0A202020202020617065782E6A5175657279282223222B746869732E6F7074696F6E732E726567696F6E4964292E7472696767657228226C6F61646564222C207B666F6F3A746869732E666F6F7D293B';
wwv_flow_api.g_varchar2_table(17) := '0D0A0D0A202020202020617065782E646562756728226D79726567696F6E706C7567696E2E5F6372656174652066696E697368656422293B0D0A202020207D2C0D0A202020200D0A202020202F2F2043616C6C6564207768656E20637265617465642C20';
wwv_flow_api.g_varchar2_table(18) := '616E64206C61746572207768656E206368616E67696E67206F7074696F6E730D0A20202020726566726573683A2066756E6374696F6E2829207B0D0A202020202020617065782E646562756728226D79726567696F6E706C7567696E2E72656672657368';
wwv_flow_api.g_varchar2_table(19) := '22293B0D0A2020202020200D0A202020202020617065782E6A5175657279282223222B746869732E6F7074696F6E732E726567696F6E4964292E747269676765722822617065786265666F72657265667265736822293B0D0A0D0A202020202020766172';
wwv_flow_api.g_varchar2_table(20) := '205F74686973203D20746869733B0D0A0D0A2020202020202F2F2063616C6C2074686520616A617820504C2F53514C2066756E6374696F6E20746F2070756C6C2074686520646174610D0A202020202020617065782E7365727665722E706C7567696E0D';
wwv_flow_api.g_varchar2_table(21) := '0A202020202020202028746869732E6F7074696F6E732E616A61784964656E7469666965720D0A20202020202020202C7B20706167654974656D733A20746869732E6F7074696F6E732E616A61784974656D73207D0D0A20202020202020202C7B206461';
wwv_flow_api.g_varchar2_table(22) := '7461547970653A20226A736F6E220D0A202020202020202020202C737563636573733A2066756E6374696F6E2820642029207B0D0A202020202020202020202020617065782E646562756728227375636365737322293B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(23) := '20617065782E6A5175657279282223222B5F746869732E6F7074696F6E732E726567696F6E4964292E7472696767657228226170657861667465727265667265736822293B0D0A2020202020202020202020200D0A2020202020202020202020202F2F20';
wwv_flow_api.g_varchar2_table(24) := '7075742074686520636F6465206865726520746F2072656E64657220746865206461746120666F7220646973706C61790D0A202020202020202020202020617065782E64656275672822726F7720636F756E74222C20642E646174612E636F756E74293B';
wwv_flow_api.g_varchar2_table(25) := '0D0A2020202020202020202020200D0A202020202020202020202020642E646174612E666F72456163682866756E6374696F6E28652C6929207B0D0A20202020202020202020202020200D0A2020202020202020202020202020617065782E6465627567';
wwv_flow_api.g_varchar2_table(26) := '2822726F772023222C20692C2022636F6C41222C20652E636F6C412C2022636F6C42222C20652E636F6C42293B0D0A0D0A2020202020202020202020207D20293B0D0A202020202020202020207D0D0A20202020202020207D20293B0D0A0D0A20202020';
wwv_flow_api.g_varchar2_table(27) := '2020617065782E646562756728226D79726567696F6E706C7567696E2E726566726573682066696E697368656422293B0D0A2020202020202F2F205472696767657220612063616C6C6261636B2F6576656E740D0A202020202020746869732E5F747269';
wwv_flow_api.g_varchar2_table(28) := '676765722820226368616E67652220293B0D0A202020207D2C0D0A0D0A202020202F2F204576656E747320626F756E6420766961205F6F6E206172652072656D6F766564206175746F6D61746963616C6C790D0A202020202F2F20726576657274206F74';
wwv_flow_api.g_varchar2_table(29) := '686572206D6F64696669636174696F6E7320686572650D0A202020205F64657374726F793A2066756E6374696F6E2829207B0D0A2020202020202F2F2072656D6F76652067656E65726174656420656C656D656E74730D0A202020207D2C0D0A0D0A2020';
wwv_flow_api.g_varchar2_table(30) := '20202F2F205F7365744F7074696F6E732069732063616C6C6564207769746820612068617368206F6620616C6C206F7074696F6E73207468617420617265206368616E67696E670D0A202020202F2F20616C776179732072656672657368207768656E20';
wwv_flow_api.g_varchar2_table(31) := '6368616E67696E67206F7074696F6E730D0A202020205F7365744F7074696F6E733A2066756E6374696F6E2829207B0D0A2020202020202F2F205F737570657220616E64205F73757065724170706C792068616E646C65206B656570696E672074686520';
wwv_flow_api.g_varchar2_table(32) := '726967687420746869732D636F6E746578740D0A202020202020746869732E5F73757065724170706C792820617267756D656E747320293B0D0A202020202020746869732E7265667265736828293B0D0A202020207D2C0D0A0D0A202020202F2F205F73';
wwv_flow_api.g_varchar2_table(33) := '65744F7074696F6E2069732063616C6C656420666F72206561636820696E646976696475616C206F7074696F6E2074686174206973206368616E67696E670D0A202020205F7365744F7074696F6E3A2066756E6374696F6E28206B65792C2076616C7565';
wwv_flow_api.g_varchar2_table(34) := '2029207B0D0A202020202020746869732E5F737570657228206B65792C2076616C756520293B0D0A202020207D2020202020200D0A0D0A20207D293B0D0A7D293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(37604097629691857)
,p_plugin_id=>wwv_flow_api.id(37453481691408215)
,p_file_name=>'sample_region_plugin.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
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
