function test(package)
    if nargin < 1
        package = 'ala_laurila_lab';
    end
    
    rootPath = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(rootPath, 'lib')));
    addpath(genpath(fullfile(rootPath, 'src')));
    
    javaaddpath(which('mpa-jutil-0.0.1-SNAPSHOT.jar'));
    javaaddpath(which('java-uuid-generator-3.1.4.jar'));
    
    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.TAPPlugin;
    import matlab.unittest.plugins.ToFile;
    import matlab.unittest.Verbosity;

    suite = TestSuite.fromPackage(package, 'IncludingSubpackages', true);
    runner = TestRunner.withTextOutput('Verbosity', Verbosity.Verbose);
    resultsFile = 'testResults.tap';

    if ismethod('TAPPlugin', 'producingVersion13')
        % new TAP plugin format and additional diagnostics
        runner.addPlugin(TAPPlugin.producingVersion13(ToFile(resultsFile)), ...
            'IncludingPassingDiagnostics', true);
    else
        % old, more compatible TAP plugin
        runner.addPlugin(TAPPlugin.producingOriginalFormat(ToFile(resultsFile)));
    end

    
    % Report test failures as an exception.
    results = runner.run(suite);
    failureCount = sum([results.Failed]);
    if failureCount > 0
        error('tbAssertTestsPass:someTestsFailed', ...
            '%d of %d tests failed from folder "%s".', ...
            failureCount, ...
            numel(results), ...
            testFolder);
    end
end
