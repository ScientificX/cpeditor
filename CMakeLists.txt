cmake_minimum_required(VERSION 3.5)

if(APPLE)
	set(CMAKE_OSX_DEPLOYMENT_TARGET "10.14" CACHE STRING "Minimum OS X deployment version")
endif()

project(cpeditor LANGUAGES CXX VERSION 6.6.0)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    SET(GUI_TYPE WIN32)
endif()

find_package(Qt5 COMPONENTS Widgets REQUIRED)
find_package(Qt5 COMPONENTS Network REQUIRED)
find_package(Qt5 COMPONENTS LinguistTools REQUIRED)
find_package(Python3 COMPONENTS Interpreter REQUIRED)

add_subdirectory(third_party/QCodeEditor)

set(QAPPLICATION_CLASS QApplication CACHE STRING "Inheritance class for SingleApplication")

add_subdirectory(third_party/singleapplication)

add_subdirectory(third_party/QtFindReplaceDialog/dialogs)

add_subdirectory(third_party/lsp-cpp)

option(PORTABLE_VERSION "Build the portable version" Off)

if(${PORTABLE_VERSION})
  message(STATUS "Will build the portable version")
else()
  message(STATUS "Will build the setup version")
endif()

IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)
  FIND_PACKAGE(Git)
  IF(GIT_FOUND)
    EXECUTE_PROCESS(
      COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      OUTPUT_VARIABLE "GIT_COMMIT_HASH"
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    MESSAGE( STATUS "Git commit hash: ${GIT_COMMIT_HASH}")
  ENDIF(GIT_FOUND)
ENDIF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)

configure_file(cmake/version.hpp.in ${CMAKE_BINARY_DIR}/generated/version.hpp)
configure_file(cmake/portable.hpp.in ${CMAKE_BINARY_DIR}/generated/portable.hpp)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/generated/SettingsHelper.hpp ${CMAKE_BINARY_DIR}/generated/SettingsInfo.hpp ${CMAKE_BINARY_DIR}/generated/SettingsInfo.cpp
                   COMMAND ${Python3_EXECUTABLE} ${PROJECT_SOURCE_DIR}/tools/genSettings.py ${PROJECT_SOURCE_DIR}/src/Settings/settings.json
                   WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                   DEPENDS ${PROJECT_SOURCE_DIR}/src/Settings/settings.json ${PROJECT_SOURCE_DIR}/tools/genSettings.py)

set(TSS ${CMAKE_SOURCE_DIR}/translations/zh_CN.ts ${CMAKE_SOURCE_DIR}/translations/ru_RU.ts)

set_source_files_properties(${TSS} PROPERTIES OUTPUT_LOCATION ${CMAKE_BINARY_DIR}/translations)

qt5_add_translation(QMFILES ${TSS})

file(COPY ${CMAKE_SOURCE_DIR}/translations/translations.qrc DESTINATION ${CMAKE_BINARY_DIR}/translations)

set_property(SOURCE ${CMAKE_BINARY_DIR}/generated/SettingsHelper.hpp ${CMAKE_BINARY_DIR}/generated/SettingsInfo.hpp ${CMAKE_BINARY_DIR}/generated/SettingsInfo.cpp PROPERTY SKIP_AUTOGEN ON)

add_executable(cpeditor
    ${GUI_TYPE}

    src/Core/Checker.cpp
    src/Core/Checker.hpp
    src/Core/Compiler.cpp
    src/Core/Compiler.hpp
    src/Core/EventLogger.cpp
    src/Core/EventLogger.hpp
    src/Core/MessageLogger.cpp
    src/Core/MessageLogger.hpp
    src/Core/Runner.cpp
    src/Core/Runner.hpp
    src/Core/StyleManager.cpp
    src/Core/StyleManager.hpp
    src/Core/Translator.cpp
    src/Core/Translator.hpp

    src/Extensions/CFTool.cpp
    src/Extensions/CFTool.hpp
    src/Extensions/ClangFormatter.cpp
    src/Extensions/ClangFormatter.hpp
    src/Extensions/CompanionServer.cpp
    src/Extensions/CompanionServer.hpp
    src/Extensions/EditorTheme.cpp
    src/Extensions/EditorTheme.hpp
    src/Extensions/LanguageServer.cpp
    src/Extensions/LanguageServer.hpp

    src/Settings/AppearancePage.cpp
    src/Settings/AppearancePage.hpp
    src/Settings/CodeSnippetsPage.cpp
    src/Settings/CodeSnippetsPage.hpp
    src/Settings/FileProblemBinder.cpp
    src/Settings/FileProblemBinder.hpp
    src/Settings/FontItem.cpp
    src/Settings/FontItem.hpp
    src/Settings/ParenthesesPage.cpp
    src/Settings/ParenthesesPage.hpp
    src/Settings/PathItem.cpp
    src/Settings/PathItem.hpp
    src/Settings/PreferencesGridPage.cpp
    src/Settings/PreferencesGridPage.hpp
    src/Settings/PreferencesHomePage.cpp
    src/Settings/PreferencesHomePage.hpp
    src/Settings/PreferencesPage.cpp
    src/Settings/PreferencesPage.hpp
    src/Settings/PreferencesPageTemplate.cpp
    src/Settings/PreferencesPageTemplate.hpp
    src/Settings/PreferencesWindow.cpp
    src/Settings/PreferencesWindow.hpp
    src/Settings/SettingsManager.cpp
    src/Settings/SettingsManager.hpp
    src/Settings/ShortcutItem.cpp
    src/Settings/ShortcutItem.hpp
    src/Settings/StringListsItem.cpp
    src/Settings/StringListsItem.hpp
    src/Settings/ValueWrapper.cpp
    src/Settings/ValueWrapper.hpp

    src/Telemetry/UpdateChecker.cpp
    src/Telemetry/UpdateChecker.hpp

    src/Util/FileUtil.cpp
    src/Util/FileUtil.hpp
    src/Util/QCodeEditorUtil.cpp
    src/Util/QCodeEditorUtil.hpp
    src/Util/Util.cpp
    src/Util/Util.hpp

    src/Widgets/DiffViewer.cpp
    src/Widgets/DiffViewer.hpp
    src/Widgets/TestCase.cpp
    src/Widgets/TestCase.hpp
    src/Widgets/TestCaseEdit.cpp
    src/Widgets/TestCaseEdit.hpp
    src/Widgets/TestCases.cpp
    src/Widgets/TestCases.hpp
    src/Widgets/UpdatePresenter.hpp
    src/Widgets/UpdatePresenter.cpp
    src/Widgets/UpdateProgressDialog.hpp
    src/Widgets/UpdateProgressDialog.cpp

    src/appwindow.cpp
    src/appwindow.hpp
    src/mainwindow.cpp
    src/mainwindow.hpp

    src/SignalHandler.cpp
    src/SignalHandler.hpp

    src/main.cpp

    third_party/diff_match_patch/diff_match_patch.h
    third_party/diff_match_patch/diff_match_patch.cpp

    ui/mainwindow.ui
    ui/appwindow.ui

    ${CMAKE_BINARY_DIR}/generated/version.hpp
    ${CMAKE_BINARY_DIR}/generated/SettingsHelper.hpp
    ${CMAKE_BINARY_DIR}/generated/SettingsInfo.hpp
    ${CMAKE_BINARY_DIR}/generated/SettingsInfo.cpp

    ${CMAKE_BINARY_DIR}/translations/translations.qrc
    resources/resources.qrc
    assets/appicon.rc)

include_directories("generated/")
include_directories("src/")
include_directories("third_party/diff_match_patch")
include_directories("third_party/lsp-cpp/include")
include_directories("third_party/QCodeEditor/include")
include_directories("third_party/QtFindReplaceDialog")

target_link_libraries(cpeditor PRIVATE LSPClient)
target_link_libraries(cpeditor PRIVATE QCodeEditor)
target_link_libraries(cpeditor PRIVATE Qt5::Network)
target_link_libraries(cpeditor PRIVATE Qt5::Widgets)
target_link_libraries(cpeditor PRIVATE QtFindReplaceDialog)
target_link_libraries(cpeditor PRIVATE SingleApplication)

if(MSVC)
    target_compile_options(cpeditor PUBLIC "/utf-8")
endif(MSVC)

if(APPLE)
    set_target_properties(cpeditor
        PROPERTIES
        MACOSX_BUNDLE TRUE
	MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/cmake/Info.plist.in
        RESOURCE ".ci/mac/cpeditor.icns"
    )
endif()

if(UNIX AND NOT APPLE)
	install(TARGETS cpeditor
		RUNTIME DESTINATION bin
        	LIBRARY DESTINATION lib)
	install(FILES .ci/linux/cpeditor.desktop DESTINATION share/applications)
	install(FILES .ci/linux/cpeditor-icon.png DESTINATION share/icons)
endif()
