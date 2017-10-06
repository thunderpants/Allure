# Copyright (c) 2008--2011 Andres Loeh, 2010--2017 Mikolaj Konarski
# This file is a part of the computer game Allure of the Stars
# and is released under the terms of the GNU Affero General Public License.
# For license and copyright information, see the file LICENSE.
#

play:
	dist/build/Allure/Allure --dbgMsgSer --dumpInitRngs

configure-debug:
	cabal configure --enable-profiling --profiling-detail=all-functions -fwith_expensive_assertions --disable-optimization

configure-prof:
	cabal configure --enable-profiling --profiling-detail=exported-functions -frelease

ghcjs-configure:
	cabal configure --disable-library-profiling --disable-profiling --ghcjs --ghcjs-option=-dedupe -f-release

chrome-prof:
	google-chrome --no-sandbox --js-flags="--logfile=%t.log --prof" ../allureofthestars.github.io/play/index.html

minific:
	ccjs dist/build/Allure/Allure.jsexe/all.js --compilation_level=ADVANCED_OPTIMIZATIONS --isolation_mode=IIFE --assume_function_wrapper --jscomp_off="*" --externs=node > ../allureofthestars.github.io/play/allure.all.js

frontendRaid:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode raid

frontendBrawl:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode brawl

frontendShootout:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode shootout

frontendEscape:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 3 --dumpInitRngs --automateAll --gameMode escape

frontendZoo:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 2 --dumpInitRngs --automateAll --gameMode zoo

frontendAmbush:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode ambush

frontendExploration:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 1 --dumpInitRngs --automateAll --gameMode exploration

frontendSafari:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 2 --dumpInitRngs --automateAll --gameMode safari

frontendSafariSurvival:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode "safari survival"

frontendBattle:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode battle

frontendBattleSurvival:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 5 --dumpInitRngs --automateAll --gameMode "battle survival"

frontendDefense:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix test --newGame 9 --dumpInitRngs --automateAll --gameMode defense


benchMemoryAnim:
	dist/build/Allure/Allure --dbgMsgSer --newGame 1 --maxFps 100000 --benchmark --stopAfterFrames 33000 --automateAll --keepAutomated --gameMode exploration --setDungeonRng 120 --setMainRng 47 --frontendNull --noAnim +RTS -s -A1M -RTS

benchBattle:
	dist/build/Allure/Allure --dbgMsgSer --newGame 3 --noAnim --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 1500 --automateAll --keepAutomated --gameMode battle --setDungeonRng 7 --setMainRng 7

benchAnimBattle:
	dist/build/Allure/Allure --dbgMsgSer --newGame 3 --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 7000 --automateAll --keepAutomated --gameMode battle --setDungeonRng 7 --setMainRng 7

benchFrontendBattle:
	dist/build/Allure/Allure --dbgMsgSer --newGame 3 --noAnim --maxFps 100000 --benchmark --stopAfterFrames 1500 --automateAll --keepAutomated --gameMode battle --setDungeonRng 7 --setMainRng 7

benchExploration:
	dist/build/Allure/Allure --dbgMsgSer --newGame 1 --noAnim --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 7000 --automateAll --keepAutomated --gameMode exploration --setDungeonRng 0 --setMainRng 0

benchFrontendExploration:
	dist/build/Allure/Allure --dbgMsgSer --newGame 1 --noAnim --maxFps 100000 --benchmark --stopAfterFrames 7000 --automateAll --keepAutomated --gameMode exploration --setDungeonRng 0 --setMainRng 0

benchNull: benchBattle benchAnimBattle benchExploration

bench: benchBattle benchAnimBattle benchFrontendBattle benchExploration benchFrontendExploration

nativeBenchExploration:
	dist/build/Allure/Allure		   --dbgMsgSer --newGame 2 --noAnim --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 2000 --automateAll --keepAutomated --gameMode exploration --setDungeonRng 0 --setMainRng 0

nativeBenchBattle:
	dist/build/Allure/Allure		   --dbgMsgSer --newGame 3 --noAnim --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 1000 --automateAll --keepAutomated --gameMode battle --setDungeonRng 0 --setMainRng 0

nativeBench: nativeBenchBattle nativeBenchExploration

nodeBenchExploration:
	node dist/build/Allure/Allure.jsexe/all.js --dbgMsgSer --newGame 2 --noAnim --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 2000 --automateAll --keepAutomated --gameMode exploration --setDungeonRng 0 --setMainRng 0

nodeBenchBattle:
	node dist/build/Allure/Allure.jsexe/all.js --dbgMsgSer --newGame 3 --noAnim --maxFps 100000 --frontendNull --benchmark --stopAfterFrames 1000 --automateAll --keepAutomated --gameMode battle --setDungeonRng 0 --setMainRng 0

nodeBench: nodeBenchBattle nodeBenchExploration


test-travis-short: test-short

test-travis: test-short test-medium benchNull

test: test-short test-medium benchNull

test-short: test-short-new test-short-load

test-medium: testRaid-medium testBrawl-medium testShootout-medium testEscape-medium testZoo-medium testAmbush-medium testExploration-medium testSafari-medium testSafariSurvival-medium testBattle-medium testBattleSurvival-medium

testRaid-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 20 --dumpInitRngs --automateAll --keepAutomated --gameMode raid 2> /tmp/teletypetest.log

testBrawl-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 20 --dumpInitRngs --automateAll --keepAutomated --gameMode brawl 2> /tmp/teletypetest.log

testShootout-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 20 --dumpInitRngs --automateAll --keepAutomated --gameMode shootout 2> /tmp/teletypetest.log

testEscape-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 3 --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 40 --dumpInitRngs --automateAll --keepAutomated --gameMode escape 2> /tmp/teletypetest.log

testZoo-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 2 --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 100 --dumpInitRngs --automateAll --keepAutomated --gameMode zoo 2> /tmp/teletypetest.log

testAmbush-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 20 --dumpInitRngs --automateAll --keepAutomated --gameMode ambush 2> /tmp/teletypetest.log

testExploration-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 1 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 200 --dumpInitRngs --automateAll --keepAutomated --gameMode exploration 2> /tmp/teletypetest.log

testSafari-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 2 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 100 --dumpInitRngs --automateAll --keepAutomated --gameMode safari 2> /tmp/teletypetest.log

testSafariSurvival-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 8 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 60 --dumpInitRngs --automateAll --keepAutomated --gameMode "safari survival" 2> /tmp/teletypetest.log

testBattle-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 3 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 20 --dumpInitRngs --automateAll --keepAutomated --gameMode battle 2> /tmp/teletypetest.log

testBattleSurvival-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 7 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 60 --dumpInitRngs --automateAll --keepAutomated --gameMode "battle survival" 2> /tmp/teletypetest.log

testDefense-medium:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 9 --noAnim --maxFps 100000 --frontendTeletype --benchmark --stopAfterSeconds 300 --dumpInitRngs --automateAll --keepAutomated --gameMode defense 2> /tmp/teletypetest.log

test-short-new:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix raid --dumpInitRngs --automateAll --keepAutomated --gameMode raid --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix brawl --dumpInitRngs --automateAll --keepAutomated --gameMode brawl --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix shootout --dumpInitRngs --automateAll --keepAutomated --gameMode shootout --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix escape --dumpInitRngs --automateAll --keepAutomated --gameMode escape --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix zoo --dumpInitRngs --automateAll --keepAutomated --gameMode zoo --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix ambush --dumpInitRngs --automateAll --keepAutomated --gameMode ambush --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix exploration --dumpInitRngs --automateAll --keepAutomated --gameMode exploration --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix safari --dumpInitRngs --automateAll --keepAutomated --gameMode safari --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix safariSurvival --dumpInitRngs --automateAll --keepAutomated --gameMode "safari survival" --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix battle --dumpInitRngs --automateAll --keepAutomated --gameMode battle --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --newGame 5 --savePrefix battleSurvival --dumpInitRngs --automateAll --keepAutomated --gameMode "battle survival" --frontendTeletype --stopAfterSeconds 2 2> /tmp/teletypetest.log

# "--setDungeonRng 0 --setMainRng 0" is needed for determinism relative to seed
# generated before game save
test-short-load:
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix raid --dumpInitRngs --automateAll --keepAutomated --gameMode raid --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix brawl --dumpInitRngs --automateAll --keepAutomated --gameMode brawl --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix shootout --dumpInitRngs --automateAll --keepAutomated --gameMode shootouti --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix escape --dumpInitRngs --automateAll --keepAutomated --gameMode escape --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix zoo --dumpInitRngs --automateAll --keepAutomated --gameMode zoo --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix ambush --dumpInitRngs --automateAll --keepAutomated --gameMode ambush --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix exploration --dumpInitRngs --automateAll --keepAutomated --gameMode exploration --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix safari --dumpInitRngs --automateAll --keepAutomated --gameMode safari --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix safariSurvival --dumpInitRngs --automateAll --keepAutomated --gameMode "safari survival" --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix battle --dumpInitRngs --automateAll --keepAutomated --gameMode battle --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log
	dist/build/Allure/Allure --dbgMsgSer --boostRandomItem --savePrefix battleSurvival --dumpInitRngs --automateAll --keepAutomated --gameMode "battle survival" --frontendTeletype --stopAfterSeconds 2 --setDungeonRng 0 --setMainRng 0 2> /tmp/teletypetest.log


build-binary-common:
	cabal install --disable-library-profiling --disable-profiling --disable-documentation -f-release --only-dependencies
	cabal configure --disable-library-profiling --disable-profiling -f-release --prefix=/ --datadir=. --datasubdir=.
	cabal build exe:Allure
	mkdir -p AllureOfTheStars/GameDefinition/fonts
	cabal copy --destdir=AllureOfTheStarsInstall
	cp GameDefinition/config.ui.default AllureOfTheStars/GameDefinition
	cp GameDefinition/fonts/16x16x.fon AllureOfTheStars/GameDefinition/fonts
	cp GameDefinition/fonts/8x8xb.fon AllureOfTheStars/GameDefinition/fonts
	cp GameDefinition/fonts/8x8x.fon AllureOfTheStars/GameDefinition/fonts
	cp GameDefinition/fonts/LICENSE.16x16x AllureOfTheStars/GameDefinition/fonts
	cp GameDefinition/fonts/Fix15Mono-Bold.woff AllureOfTheStars/GameDefinition/fonts
	cp GameDefinition/fonts/LICENSE.Fix15Mono-Bold AllureOfTheStars/GameDefinition/fonts
	cp GameDefinition/PLAYING.md AllureOfTheStars/GameDefinition
	cp GameDefinition/InGameHelp.txt AllureOfTheStars/GameDefinition
	cp README.md AllureOfTheStars
	cp CHANGELOG.md AllureOfTheStars
	cp LICENSE AllureOfTheStars
	cp CREDITS AllureOfTheStars

build-binary: build-binary-common
	cp AllureOfTheStarsInstall/bin/Allure AllureOfTheStars
	tar -czf Allure_x_ubuntu-16.04-amd64.tar.gz AllureOfTheStars
