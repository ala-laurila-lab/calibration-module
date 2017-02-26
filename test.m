function test(package)
    if nargin < 1
        package = 'ala_laurila_lab';
    end
    
    rootPath = fileparts(mfilename('fullpath'));
    addpath(genpath(fullfile(rootPath, 'lib')));
    addpath(genpath(fullfile(rootPath, 'src')));
    
    javaaddpath(which('mpa-jutil-0.0.1-SNAPSHOT.jar'));
    javaaddpath(which('java-uuid-generator-3.1.4.jar'));
    
    suite = matlab.unittest.TestSuite.fromPackage(package, 'IncludingSubpackages', true);
    results = run(suite);
    
    failed = sum([results.Failed]);
    if failed > 0
        error([num2str(failed) ' test(s) failed!']);
    end
    
end
