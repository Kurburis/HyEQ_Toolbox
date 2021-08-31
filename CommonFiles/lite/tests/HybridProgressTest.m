classdef HybridProgressTest < matlab.unittest.TestCase

    methods (Test)
        
        function testTimeSpans(testCase)    
            hp = AutoCancelHybridProgress();
            sys = ExampleBouncingBallHybridSystem();
            config = HybridSolverConfig().progress(hp);
            tspan = [0, 10];
            jspan = [0, 10];
            sys.solve([10; 0], tspan, jspan, config);
            
            testCase.assertEqual(hp.tspan, tspan);
            testCase.assertEqual(hp.jspan, jspan);
        end
        
        function testCancelDuringFlow(testCase)    
            hp = AutoCancelHybridProgress();
            hp.t_cancel = 3.0;
            hp.j_cancel = Inf;
            
            max_step = 1e-2;
            config = HybridSolverConfig("MaxStep", 1e-2).progress(hp);
            sys = ExampleBouncingBallHybridSystem();
            tspan = [0, 10];
            jspan = [0, 10];
            sol = sys.solve([10; 0], tspan, jspan, config);

            testCase.assertLessThanOrEqual(sol.t, hp.t_cancel+max_step);
            testCase.assertEqual(sol.termination_cause, TerminationCause.CANCELED)
        end
        
        function testCancelAtJump(testCase)
            hp = AutoCancelHybridProgress();
            hp.t_cancel = Inf;
            hp.j_cancel = 3;
            
            sys = ExampleBouncingBallHybridSystem();
            config = HybridSolverConfig().progress(hp);
            tspan = [0, 10];
            jspan = [0, 10];
            sol = sys.solve([10; 0], tspan, jspan, config);
            
            testCase.assertEqual(sol.j(end), hp.j_cancel);
            testCase.assertEqual(sol.termination_cause, TerminationCause.CANCELED)
        end
        function testNoCancel(testCase)
            hp = AutoCancelHybridProgress();
            hp.t_cancel = Inf;
            hp.j_cancel = Inf;
            sys = ExampleBouncingBallHybridSystem();
            config = HybridSolverConfig().progress(hp);
            sol = sys.solve([10; 0], [0, 10], [0, 10], config);
            
            testCase.assertNotEqual(sol.termination_cause, TerminationCause.CANCELED)
        end
        
        function testOpenProgressBar(testCase)
            hp = PopupHybridProgress();
            hp.min_delay = 0;
            
            config = HybridSolverConfig().progress(hp);
            sys = ExampleBouncingBallHybridSystem();
            tspan = [0, 1];
            jspan = [0, 1];
            sys.solve([10; 0], tspan, jspan, config);
            
            testCase.assertGreaterThan(hp.update_count, 0);
        end
        
        function testProgressBarDecimalPlaces(testCase)
            hp = PopupHybridProgress();
            hp.min_delay = 0;
            hp.t_decimal_places = 1;
            
            config = HybridSolverConfig("MaxStep", 1e-2).progress(hp);
            sys = ExampleBouncingBallHybridSystem();
            tspan = [0, 1];
            jspan = [0, 1];
            sys.solve([10; 0], tspan, jspan, config);
              
            testCase.assertEqual(hp.update_count, 10/tspan(2) + 1);            
        end
        
        function testNoOpenProgressBarWhenLargeDelay(testCase)
            hp = PopupHybridProgress();
            hp.min_delay = Inf;
            
            config = HybridSolverConfig().progress(hp);
            sys = ExampleBouncingBallHybridSystem();
            tspan = [0, 1];
            jspan = [0, 1];
            sys.solve([10; 0], tspan, jspan, config);
              
            testCase.assertEqual(hp.update_count, 0);            
        end
    end

end 