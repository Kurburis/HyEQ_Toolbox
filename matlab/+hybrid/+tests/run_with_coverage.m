import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

toolbox_matlab_dir = fullfile(proj_root, 'matlab');
suite = TestSuite.fromPackage('hybrid.tests');

% Create a test runner.
runner = TestRunner.withTextOutput;

% Add CodeCoveragePlugin to the runner and run the tests.
runner.addPlugin(CodeCoveragePlugin.forFolder(toolbox_matlab_dir, ...
                    'IncludingSubfolders', true))
result = runner.run(suite);