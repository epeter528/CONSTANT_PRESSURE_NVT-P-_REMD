program WRITE_MDP

implicit none

integer         :: i,p

integer              :: dark_or_light

character(len=4)  :: c11

real  ,dimension(1000)         :: temp

character(len=200)             :: mdpfilename

character(len=50)   :: startname

integer :: natoms,u

real (kind=8) :: box_x,box_y,box_z

open(unit=4,file='temperature_volume.xvg')
open(unit=1,file='temp.txt')

p = 0

do 

        read(1,*,end=1,err=1) temp(p)
        
        p = p + 1
        
enddo        

1 continue


do i=0,p-1

 if(i .lt. 10) then

 write(mdpfilename,'(a4,i1,a4)') 'temp',i,'.mdp'
 
 endif
 
 if(i .ge. 10) then

 write(mdpfilename,'(a4,i2,a4)') 'temp',i,'.mdp'
 
 endif 

 if(i .lt. 10) then

 write(startname,'(a6,i1,a4)') 'start_',i,'.gro' 

else

 write(startname,'(a6,i2,a4)') 'start_',i,'.gro' 

endif

 open(unit=3,file=trim(startname),status='old') 

 read(3,*)
 read(3,*) natoms

 do u=1,natoms

   read(3,*)

 enddo

  read(3,*) box_x,box_y,box_z

close(unit=3)

 write(4,*) temp(i), box_x*box_y*box_z

 open(unit=432,file=trim(mdpfilename))

 write(432,*) 'title                    = implicit prod.'

 write(432,*) ';Preprocessor'
 write(432,*) 'cpp			 = /lib/cpp'
 write(432,*) ';Directories to include in the topology format'
 write(432,*) 'include 		 = -I../top'
 write(432,*) ';Run control: A leap-frog algorithm for integrating Newtons equations.' 
 write(432,*) 'integrator		 = md'
 write(432,*) ';Total simulation time: 100 ps'
 write(432,*) ':time step in femtoseconds'  
 write(432,*) 'dt			 = 0.001'
 write(432,*) ';number of steps'
 write(432,*) 'nsteps  		 =  100000000'
 write(432,*) 'comm_mode         =  linear '
 write(432,*) ';frequency to write coordinates to output trajectory file'
 write(432,*) 'nstxout 		 = 1500 '
 write(432,*) ';frequency to write velocities to output trajectory file'
 write(432,*) 'nstvout 		 = 1500 '
 write(432,*) ';frequency to write energies to log file'
 write(432,*) 'nstlog  		 = 1500 '
 write(432,*) ';frequency to write energies to energy file'
 write(432,*) 'nstenergy		 = 1500 '
 write(432,*) ';frequency to write coordinates to xtc trajectory' 
 write(432,*) 'nstxtcout		 = 1500 '
 write(432,*) ';group(s) to write to xtc trajectory'
 write(432,*) 'xtc_grps		 = system '  
 write(432,*) 'group(s) to write to energy file' 
 write(432,*) 'energygrps		 = sol'
 write(432,*) ';Frequency to update the neighbor list (and the long-range forces,' 
 write(432,*) ';when using twin-range cut-offs).' 
 write(432,*) 'nstlist 		 = 5'
 write(432,*) ';Make a grid in the box and only check atoms in neighboring grid cells'
 write(432,*) ';when constructing a new neighbor list every nstlist steps.' 
 write(432,*) 'ns_type 		 = grid'
 write(432,*) ';cut-off distance for the short-range neighbor list'
 write(432,*) 'rlist		 = 1.0 '
 write(432,*) ';treatment of electrostatic interactions'
 write(432,*) 'coulombtype		 = pme '
 write(432,*) 'pme_order            = 4'
 write(432,*) 'fourierspacing       = 0.12' 
 write(432,*) 'rcoulomb		 = 1.0' 
 write(432,*) ';treatment of van der waals interactions'
 write(432,*) 'vdwtype           = shift '
 write(432,*) 'rvdw			 = 1.0'
 write(432,*) '; Periodic boudary conditions in all the directions' 
 write(432,*) 'pbc                      = xyz'
 write(432,*) ';Temperature coupling'
 write(432,*) 'tcoupl  		 = nose-hoover '
 write(432,*) 'tc-grps 		 = system'   
 write(432,*) 'tau_t	        =  1.0 ' 
 write(432,'(a22,f7.2)') 'ref_t		 = ',temp(i)
! write(432,*) 'bd_fric           = 3000' 
 write(432,*) ';Pressure coupling'
 write(432,*) 'Pcoupl  		 = no '
 write(432,*) 'Pcoupltype           = isotropic'
 write(432,*) 'tau_p		 = 1.0'
 write(432,*) 'compressibility 	 = 4.5e-5'
 write(432,*) 'ref_p		 = 1.0'
 write(432,*) ';Velocity generation'
 write(432,*) 'gen_vel 		 = yes' 
 write(432,'(a25,f7.2)') 'gen_temp		 = ',temp(i)
 write(432,*) 'gen_seed		 = 173529'
 write(432,*) ';Constrain all bonds'
 write(432,*) 'constraints		 = none'

 close(unit=432)


call system('rm -f ./grompp.sh')

open(unit=1,file = 'grompp.sh')

write(1,*) '#!/bin/bash'

if(i .lt. 10) then

    write(1,'(a55,a10,a23,i1,a14,i1,a4)') 'grompp -maxwarn 2 -f ', mdpfilename, ' -p start.top -c start_',i,'.gro -o topol_',i,'.tpr'

endif

if(i .ge. 10) then

    write(1,'(a55,a10,a23,i2,a14,i2,a4)') 'grompp -maxwarn 2 -f ', mdpfilename, ' -p start.top -c start_',i,'.gro -o topol_',i,'.tpr'

endif

close(unit=1)

call system('chmod 744 grompp.sh')

call system('./grompp.sh')

call system('rm -f ./#*#')

enddo

close(unit=4)

end program WRITE_MDP
