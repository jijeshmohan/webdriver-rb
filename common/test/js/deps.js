// All paths are relative to third_party/goog/base.js as served by the test
// server: common/test/java/org/openqa/selenium/environment/webserver/Jetty6AppServer.java
goog.addDependency('../../js/src/abstractcommandprocessor.js',
                   ['webdriver.AbstractCommandProcessor'],
                   ['goog.Disposable', 'goog.array', 'webdriver.CommandName',
                    'webdriver.Context', 'webdriver.Future',
                    'webdriver.Response', 'webdriver.timing']);
goog.addDependency('../../js/src/asserts.js',
                   ['webdriver.asserts', 'webdriver.asserts.Matcher'],
                   ['goog.math.Coordinate', 'webdriver.Future']);
goog.addDependency('../../js/src/by.js',
                   ['webdriver.By', 'webdriver.By.Locator',
                    'webdriver.By.Strategy'],
                   ['goog.object']);
goog.addDependency('../../js/src/command.js',
                   ['webdriver.Command', 'webdriver.CommandName',
                    'webdriver.Response'],
                   ['goog.array']);
goog.addDependency('../../js/src/context.js', ['webdriver.Context'], []);
goog.addDependency('../../js/src/factory.js', ['webdriver.factory'],
                   ['goog.userAgent', 'webdriver.LocalCommandProcessor',
                    'webdriver.WebDriver']);
goog.addDependency('../../js/src/future.js', ['webdriver.Future'],
                   ['goog.events.EventType', 'goog.events.EventTarget']);
goog.addDependency('../../js/src/key.js', ['webdriver.Key'], ['goog.array']);
goog.addDependency('../../js/src/localcommandprocessor.js',
                   ['webdriver.LocalCommandProcessor'],
                   ['goog.array', 'goog.dom', 'goog.events', 'goog.json',
                    'goog.object', 'webdriver.AbstractCommandProcessor',
                    'webdriver.CommandName', 'webdriver.Context',
                    'webdriver.Response']);
goog.addDependency('../../js/src/logging.js',
                   ['webdriver.logging', 'webdriver.logging.Level'],
                   ['goog.dom']);
goog.addDependency('../../js/src/testrunner.js',
                   ['webdriver.TestCase', 'webdriver.TestResult',
                    'webdriver.TestRunner'],
                   ['goog.Uri', 'goog.dom', 'goog.style', 'webdriver.factory',
                    'webdriver.logging', 'webdriver.WebDriver.EventType',
                    'webdriver.timing']);
goog.addDependency('../../js/src/timing.js', ['webdriver.timing'], ['goog.userAgent']);
goog.addDependency('../../js/src/wait.js',
                   ['webdriver.Wait'],
                   ['goog.events', 'webdriver.Future', 'webdriver.timing']);
goog.addDependency('../../js/src/webdriver.js',
                   ['webdriver.WebDriver', 'webdriver.WebDriver.EventType'],
                   ['goog.events', 'goog.events.EventTarget',
                    'webdriver.Command', 'webdriver.CommandName',
                    'webdriver.Context', 'webdriver.Future',
                    'webdriver.Response', 'webdriver.Wait',
                    'webdriver.WebElement', 'webdriver.logging',
                    'webdriver.timing']);
goog.addDependency('../../js/src/webelement.js', ['webdriver.WebElement'],
                   ['goog.array', 'goog.math.Coordinate',
                    'goog.math.Size', 'webdriver.Command',
                    'webdriver.CommandName', 'webdriver.Future',
                    'webdriver.By.Locator', 'webdriver.By.Strategy']);
