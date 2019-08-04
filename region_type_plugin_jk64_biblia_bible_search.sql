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
,p_default_workspace_id=>5238514445419534
,p_default_application_id=>110
,p_default_owner=>'CHURCH'
);
end;
/
prompt --application/shared_components/plugins/region_type/jk64_biblia_bible_search
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(37184172667428334)
,p_plugin_type=>'REGION TYPE'
,p_name=>'JK64.BIBLIA.BIBLE_SEARCH'
,p_display_name=>'Bible Search'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function render (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean )',
'return apex_plugin.t_region_render_result',
'as',
'    subtype plugin_attr is varchar2(32767);',
'',
'    l_result                 apex_plugin.t_region_render_result;',
'    buf                      varchar2(32767);',
'',
'    -- Component attributes',
'    l_bible_version          plugin_attr := p_region.attribute_01;',
'    l_style                  plugin_attr := p_region.attribute_02;',
'    l_size                   plugin_attr := p_region.attribute_03;',
'',
'    l_width                  number;',
'    l_height                 number;',
'    ',
'begin',
'    apex_plugin_util.debug_region (',
'        p_plugin => p_plugin,',
'        p_region => p_region,',
'        p_is_printer_friendly => p_is_printer_friendly);',
'',
'    apex_javascript.add_library',
'        (p_name           => ''logos.biblia.js''',
'        ,p_directory      => ''//biblia.com/api/''',
'        ,p_skip_extension => true);',
'        ',
'    apex_javascript.add_onload_code(p_code => ''logos.biblia.init();'');',
'    ',
'    l_bible_version := nvl(l_bible_version,''esv'');',
'    l_style := nvl(l_style,''light'');',
'    l_size := nvl(l_size, ''large'');',
'    ',
'    case l_size',
'    when ''small'' then',
'        l_width  := 160;',
'        l_height := 200;',
'    when ''large'' then',
'        l_width  := 300;',
'        l_height := 400;',
'    end case;',
'',
'    buf := replace(replace(replace(replace(replace(q''[',
'    <biblia:biblesearchresults resource="%VERSION%" style="%STYLE%" size="%SIZE%" width="%WIDTH%" height="%HEIGHT%"></biblia:biblesearchresults>',
'    ]''',
'        ,''%VERSION%'', l_bible_version)',
'        ,''%STYLE%'',   l_style)',
'        ,''%SIZE%'',    l_size)',
'        ,''%WIDTH%'',   l_width)',
'        ,''%HEIGHT%'',  l_height);',
'',
'    sys.htp.p(buf);',
'',
'    return l_result;',
'end render;'))
,p_api_version=>2
,p_render_function=>'render'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Renders a Bible Search Results plugin from Biblia.com.',
'<p>',
'For more info: https://biblia.com/plugins/BibleSearchResults'))
,p_version_identifier=>'0.1'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37193456978573897)
,p_plugin_id=>wwv_flow_api.id(37184172667428334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Bible Version'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'esv'
,p_display_length=>15
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Select the book code for the Bible Version to use. The following book codes may be chosen, or use any book codes listed at https://biblia.com/plugins/BibleSearchResults (in the generated html code look for the code, e.g. <code>resource="esv"</code>).',
'<p>',
'Substitution variable may be used to determine the version from an item on the page, e.g. <code>&P1_BIBLE_VERSION.</code>',
'<hr>',
'<ul>',
'<li><b>asv</b> - American Standard Version</li>',
'<li><b>esv</b> - English Standard Version</li>',
'<li><b>gnb</b> - The Good News Translation</li>',
'<li><b>kjv</b> - King James Version</li>',
'<li><b>kjv1900</b> - King James Version (1900)</li>',
unistr('<li><b>lbla95</b> - La Biblia de las Am\00E9ricas</li>'),
'<li><b>message</b> - The Message</li>',
'<li><b>nasb95</b> - New American Standard Bible (1995)</li>',
'<li><b>ncv</b> - New Century Version</li>',
'<li><b>nirv</b> - New International Reader''s Version</li>',
'<li><b>niv2011</b> - The New International Version</li>',
'<li><b>nkjv</b> - The New King James Version</li>',
'<li><b>nlt</b> - New Living Translation</li>',
'<li><b>nrsv</b> - The New Revised Standard Version</li>',
unistr('<li><b>rst</b> - \0420\0443\0441\0441\043A\0438\0439 \0421\0438\043D\043E\0434\0430\043B\044C\043D\044B\0439 \041F\0435\0440\0435\0432\043E\0434 (1876/1956)</li>'),
'<li><b>rsv</b> - The Revised Standard Version</li>',
'<li><b>ylt</b> - Young''s Literal Translation</li>',
unistr('<li><b>hlybblsmpshndtn</b> - \4E2D\6587\5723\7ECF\548C\5408\672C\FF0D\795E\7248 (\7B80\4F53)</li>'),
unistr('<li><b>hlybbltrdshndtn</b> - \7E41\9AD4\4E2D\6587\8056\7D93\548C\5408\672C\FF0D\795E\7248</li>'),
unistr('<li><b>ko-krv</b> - \C131\ACBD\C804\C11C \AC1C\C5ED\D55C\AE00\D310 (Korean Revised Version)</li>'),
'</ul>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37193793663576209)
,p_plugin_id=>wwv_flow_api.id(37184172667428334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Style'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'light'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37194004184576692)
,p_plugin_attribute_id=>wwv_flow_api.id(37193793663576209)
,p_display_sequence=>10
,p_display_value=>'light'
,p_return_value=>'light'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37194443181577117)
,p_plugin_attribute_id=>wwv_flow_api.id(37193793663576209)
,p_display_sequence=>20
,p_display_value=>'dark'
,p_return_value=>'dark'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37194854397580694)
,p_plugin_id=>wwv_flow_api.id(37184172667428334)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Size'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'large'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37195213101581125)
,p_plugin_attribute_id=>wwv_flow_api.id(37194854397580694)
,p_display_sequence=>10
,p_display_value=>'Small (160 x 200)'
,p_return_value=>'small'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(37195649216581561)
,p_plugin_attribute_id=>wwv_flow_api.id(37194854397580694)
,p_display_sequence=>20
,p_display_value=>'Large (300 x 400)'
,p_return_value=>'large'
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
