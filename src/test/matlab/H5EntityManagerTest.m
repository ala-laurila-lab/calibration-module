classdef H5EntityManagerTest < matlab.unittest.TestCase
    
    properties(Constant)
        RIG = 'A';
    end
    
    methods(Test)
        function testCreate(obj)
            em = EntityManagerFactory(obj.RIG).create();
            obj.verifyNotEmpty(em.fname);
            em.create();
            obj.verifyEqual(exist(em.fname, 'file'), 2);
        end
        
        function testPersistAndFind(obj)
            em = EntityManagerFactory(obj.RIG).create();
            ndf = entity.NDF('A1B');
            
            v = [1; 1; 2; 2];
            p = [2.2E-12; 2.1E-12; 10E-6; 11E-6];
            rp = [1E-12; 1E-12; 5E-6; 5E-6];
            
            ndf.voltages = v;
            ndf.powers = p;
            ndf.referencePowers = rp;
            
            ndf.prepareInsertStatement();
            em.persist(ndf);
            % create new ndf object
            ndf = entity.NDF('A1B');
            ndf.prepareSelectStatement();
            em.find(ndf);
            obj.verifyEqual(ndf.voltages, int32(v));
            obj.verifyEqual(ndf.powers, p);
            obj.verifyEqual(ndf.referencePowers, rp);
            
            ndf = entity.NDF('A1B');
            ndf.prepareSelectStatement(date); 
            em.find(ndf);
            obj.verifyEqual(ndf.voltages, int32(v));
            obj.verifyEqual(ndf.powers, p);
            obj.verifyEqual(ndf.referencePowers, rp);
        end
        
    end
    
end

