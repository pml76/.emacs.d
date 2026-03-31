My Emacs Config

to install do:

   - rm ~/.emacs.d
     ( or delete c:\Users\<user>\AppData\Roaming\.emacs.d if you are
       on windows )

   - cd ~
     ( or cd c:\Users\<user>\AppData\Roaming\ if you are on windows )

   - run emacs and wait. Should an error occure, do the following:
   
     mkdir straight && cd straight && mkdir repos && cd repos
     git clone https://github.com/radian-software/straight.el.git
     cd ../..

   - when on windows, install the fonts located at
     ...\.emacs.d\straight\repos\nerd-icons.el\fonts\*


done ;)

