PROGRAM separa_files_per_quote 
! Codice per scrivere separare un file con le temperature in tre files a seconda della classe di quota   
! 2018 - Paolo  

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
!Dichiarazione variabili 
IMPLICIT NONE 
 INTEGER,PARAMETER   :: nrighemax=50000  
 INTEGER,PARAMETER   :: nmaxstaz=3000 
 INTEGER             :: i,ios,k,quota        
 CHARACTER(7),DIMENSION(nrighemax) :: codstaz   
 CHARACTER(60),DIMENSION(nrighemax) :: resto 
 CHARACTER(80),DIMENSION(nrighemax) :: datok  
 CHARACTER(7) :: codstaz2 
 CHARACTER(100)      :: filein,fileanag   
!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
!Acquisizione parametri esterni: datainizio, datafine, area (su cui si lavora)  
 CALL getarg(1,filein) 
 CALL getarg(2,fileanag) 
!################################################################################################################  

      OPEN(unit=10,file=fileanag,status='old',iostat=ios)  
      if (ios/=0) then 
        print *,'ERRORE in apertura fileanag ', fileanag    
        stop 
      endif        

      OPEN(unit=11,file=filein,status='old',iostat=ios)  
      if (ios/=0) then 
        print *,'ERRORE in apertura filein ', filein   
        stop 
      endif              

      OPEN(unit=12,file="fileout700.txt",status='unknown',iostat=ios)  
      if (ios/=0) then 
        print *,'ERRORE in apertura fileout700 '     
        stop 
      endif    

      OPEN(unit=13,file="fileout1500.txt",status='unknown',iostat=ios)  
      if (ios/=0) then 
        print *,'ERRORE in apertura fileout1500 '     
        stop 
      endif  
      
      OPEN(unit=14,file="fileout3000.txt",status='unknown',iostat=ios)  
      if (ios/=0) then 
        print *,'ERRORE in apertura fileout3000 '     
        stop 
      endif        
       
letturafilein:DO k=1,nrighemax               
   READ(11,"(a7,a60)",iostat=ios) codstaz(k),resto(k)    
   if (ios/=0) then 
     !print *,'fine lettura filein, esco, riga ',k    
     exit letturafilein 
   endif  
   letturaanag:DO i=1,nmaxstaz 
     READ(10,"(a7,40x,i4)",iostat=ios) codstaz2,quota   
     write(99,*) quota          	
     if (ios/=0) then 
       !print *,'fine lettura fileanag, esco, riga ',i   
       rewind(10)   
       exit letturaanag  
     endif   
     if (codstaz2 == codstaz(k)) then 
       if (quota<=700) then 
         write(12,"(a7,a60)") codstaz(k),resto(k) 
       else if(quota<=1500) then 
         write(13,"(a7,a60)") codstaz(k),resto(k) 
       else 
         write(14,"(a7,a60)") codstaz(k),resto(k)        
       endif 
       rewind(10) 
       exit letturaanag 
     endif 
   ENDDO letturaanag 
ENDDO  letturafilein 

close(10) 
close(11) 
close(12) 
close(13) 
close(14) 
   
END PROGRAM separa_files_per_quote  
