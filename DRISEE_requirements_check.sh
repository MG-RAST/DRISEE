!# /bin/usr/shell
# This is a quick script to see if you have the requirements 
# installed for DRISEE

echo
echo "Checking for DRISEE requirements"
echo

my_count=0

echo "You must have perl installed - checking ..."
my_perl=`which perl`
if [[ $my_perl =~ "perl" ]]; then  
    echo " OK"
    echo "     perl status - perl is installed here: "$my_perl
    echo "     check to make sure that your version is 5.12.1 or later"
    echo "          (the path above should tell you the version number)"
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
    my_count=1
else
    echo "PROBLEM"
    echo "     perl status - perl is not installed"
    echo "          try here: http://www.perl.org/get.html"
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
fi
echo

echo "You must have python installed - checking ..."
my_python=`which python`
if [[ $my_python =~ "python" ]]; then
    echo " OK"
    echo "     python status - python is installed here: "$my_python
    echo "     make sure that your version is 2.6 or later"
    echo "          (the path above should tell you the version number)"
    echo "     also make sure that you have biopython installed: http://biopython.org/wiki/Biopython"
    my_count=2
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
else
    echo "PROBLEM"
    echo "     python status - perl is not installed"
    echo "          try here: http://python.org/getit/"
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
fi
echo

echo "You must have uclust installed - checking ..."
my_uclust=`which uclust`
if [[ $my_uclust =~ "uclust" ]]; then
    echo " OK"
    echo "     uclust status - uclust is installed here: "$my_uclust
    my_count=3
else
    echo "PROBLEM"
    echo "     uclust status - uclust is not installed"
    echo "          try here:  http://www.drive5.com/usearch/nonprofit_form.html"
    echo "          email:    robert@drive5.com"
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
fi
echo

echo "You must have cdbfasta and cdbyank installed - checking ..."
my_cdbfasta=`which cdbfasta`
my_cdbyank=`which cdbyank`
if [[ $my_cdbfasta =~ "cdbfasta" ]]; then
    echo " OK"
    echo "     cdbfasta status - cdbfasta is installed here: "$my_cdbfasta
    my_count=4
else
    echo "PROBLEM"
    echo "     cdbfasta status - cdbfasta is not installed"
    echo "          try here: http://sourceforge.net/projects/cdbfasta/"
    echo "          email: email: gpertea@tigr.org"
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
fi
if [[ $my_cdbyank =~ "cdbyank" ]]; then
    echo " OK"
    echo "     cdbyank status - cdbyank is installed here: "$my_cdbyank
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
    my_count=5
else
    echo "PROBLEM"
    echo "     cdbyank status - cdbyank is not installed"
    echo "          try here: http://sourceforge.net/projects/cdbfasta/"
    echo "          email: email: gpertea@tigr.org"
    echo
    echo " * Please note that users are responsible for making sure that their use of required"
    echo "software products is compliant with existing licenses and/or user agreements
    echo
fi

echo
echo "you have ("$my_count")/(5) requirements installed" 
if [ $my_count == 5 ];then
    echo "you can install and run DRISEE"
else
    echo "you are missing one or more requirements - please see the notes above"
    echo "you will not be able to run DRISEE until all requirements are met"
fi