
# Siedler5 CommunityLib

Eine Sammlung von kleinen und größeren Scriptteilen für Siedler 5 DedK.

## Benutzung
- download:
	- git submodule [https://git-scm.com/book/en/v2/Git-Tools-Submodules]
	- oder: datei als zip runterladen
	- einzelne dateien kopieren
	- oder: mcbPacker.require nutzen (packer/devLoad.lua)
- benutzungsanleitung (1. kommentar der datei lesen)
- requirements beachten (oder von mcbPacker verwalten lassen)

## Hinzufügen
- jede comfort in eigener Datei
- benutzungsanleitung als 1. kommentar der datei
- 4 wichtige informationen für jede datei:
	- ursprünglucher autor: kommentar 'author'
	- aktuelle ansprechperson: kommentar 'current maintainer'
	- version: kommentar, bei größeren projekten zusätzlich in lua variable
	- requirements: im kommentar und (wenn möglich) als mcbPacker.require
- eigener branch mit namen (evt zweck)
- pull request

## Ändern vorhandener Funktionen:
- zuerst den 'current maintainer' fragen
- wenn nicht mehr erreichbar: sich selbst als 'current maintainer' eintragen
- eigener branch mit namen (evt zweck)
- pull request

## Eigene branches
- wichtig ist nur der status beim pull request, solange sich niemand beschwert

## Automatische Aktualisierung der S5LibLastCommit.lua (Version):
- den Befehl `git config core.hooksPath githooks` ausführen, um den vorhandenen git hook zu aktivieren.

## Lizenz
- wenn nicht extra in der Datei etwas anderes steht, gilt die MIT lizenz (die erlaubt praktisch alles, ohne Schadensersatzansprüche)
