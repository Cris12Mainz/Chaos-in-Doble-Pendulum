!THIS PROGRAM INTEGRATES THE EQUATIONS OF MOTION OF A DOUBLE PENDULUM
!DESCRIPTION OF THE DOUBLE PENDULUM:
!TWO IDENTICAL THIN RODS CONNECTED BY A PIVOD AND THE END OF THE UPPER ROD SUSPENDED FROM A PIVOT
program double_pendulum

	implicit none
	
	!NON-MODIFIABLE PARAMETERS: PI
	real, parameter :: pi = 4*atan(1.0)
	!MODIFIABLE PARAMETERS: MASS, LENGTH, GRAVITATIONAL ACCELERATION, TIME STEP
	real, parameter :: l = 1.0, g = 9.81, dt = 1.d-1
	!ANGULAR FREQUENCY SQUARED
	real, parameter :: w2 = g/l, tol = 10000*sqrt(l/g)
	!COUNTERS
	integer k, xstep, ystep
	!GRID DIMENSION
	integer, parameter :: d = 500
	!COORDINATES AND MOMENTA, TIME ON THE GRID, TIME VARIABLE
	real y(4), time(d,d), t
	
	do xstep = 1, d
		do ystep = 1, d
			!INITIAL TIME
			t = 0.0
			!INITIAL CONDITIONS (/ THETA_1, THETA_2, MOMENTUM_1, MOMENTUM_2 /)
			y = (/ -pi+2*pi*(xstep-1)/(d-1), -pi+2*pi*(ystep-1)/(d-1), 0.0, 0.0 /)
			
			if (3*cos(y(1))+cos(y(2)) <= 2) then
				!FLIP CONDITION WITHIN TOLERANCE TIME
				do while (abs(y(2)) <= pi .and. t <= tol)
					call gl10(y, dt)
					t = t + dt
				end do
				time(xstep,ystep) = t
			else
				!VIOLATION OF THE FLIP CONDITION
				time(xstep,ystep) = tol + dt
			end if
		end do
	end do
	
	do ystep = 1, d
    		write(*,*)(time(xstep,ystep), xstep = 1, d)
	end do

	contains
	
	!EVALUATE DERIVATIVES
	subroutine evalf(y, dydx)
		real y(4), dydx(4)
	        
		dydx(1) = 6 * (2*y(3) - 3*y(4)*cos(y(1)-y(2))) / (16.0 - 9*cos(y(1)-y(2))**2)
		dydx(2) = 6 * (8*y(4) - 3*y(3)*cos(y(1)-y(2))) / (16.0 - 9*cos(y(1)-y(2))**2)
		dydx(3) = (-0.5) * ( dydx(1)*dydx(2)*sin(y(1)-y(2)) + 3*w2*sin(y(1)))
		dydx(4) = (-0.5) * (-dydx(1)*dydx(2)*sin(y(1)-y(2)) +   w2*sin(y(2)))
	end subroutine evalf
	
	!10TH ORDER IMPLICIT GAUSS-LEGENDRE INTEGRATOR
	subroutine gl10(y, dt)
		integer, parameter :: s = 5, n = 4
		real y(n), g(n,s), dt
		integer i, j
		
		!BUTCHER TABLEAU FOR 10TH ORDER GAUSS-LEGENDRE METHOD
		real, parameter :: a(s,s) = reshape((/ &
			0.592317212640472718785660101799793407Q-1 , -0.195703643590760374926432140508840600Q-1, &
			0.112544008186429555527162442150907488Q-1 , -0.559379366081218487681772196447592822Q-2, &
			0.158811296786599853936524247059341622Q-2 ,  0.128151005670045283496166848329513822Q0 , &
			0.119657167624841617010322878708909548Q0  , -0.245921146196422003893182516860040166Q-1, &
			0.103182806706833574089539450563558395Q-1 , -0.276899439876960304428263075887959577Q-2, &
			0.113776288004224602528741273815365577Q0  ,  0.260004651680641518592405895187573979Q0 , &
			0.142222222222222222222222222222222222Q0  , -0.206903164309582845717601377697548829Q-1, &
			0.468715452386994122839074654459310446Q-2 ,  0.121232436926864146801414651118838277Q0 , &
			0.228996054578999876611691812361463257Q0  ,  0.309036559064086644833762696130448461Q0 , &
			0.119657167624841617010322878708909548Q0  , -0.968756314195073973903482796955514087Q-2, &
			0.116875329560228545217766777889365265Q0  ,  0.244908128910495418897463479382295025Q0 , &
			0.273190043625801488891728200229353696Q0  ,  0.258884699608759271513288971468703157Q0 , &
			0.592317212640472718785660101799793407Q-1 /), (/s,s/))
	        real, parameter ::   b(s) = (/ &
			0.118463442528094543757132020359958681Q0  , 0.239314335249683234020645757417819096Q0  , &
			0.284444444444444444444444444444444444Q0  , 0.239314335249683234020645757417819096Q0  , &
			0.118463442528094543757132020359958681Q0  /)
	        
		!ITERATE TRIAL STEPS
		g = 0.0
		do j = 1, 16
			g = matmul(g,a)
			do i = 1, s
				call evalf(y + g(:,i)*dt, g(:,i))
			end do
		end do
	        
		!UPDATE THE SOLUTION
		y = y + matmul(g,b)*dt
	end subroutine gl10

end program

