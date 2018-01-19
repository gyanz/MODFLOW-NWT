from __future__ import print_function
import os
import sys
import shutil
import traceback
import pymake
from pymake.download import download_and_unzip

def flag_available(x):
    # dummy function used to disable pymake's floating point arithmetic 
    # error check compile flag during normal build
    return 0

pymake.pymake.flag_available = flag_available 

def make_mfnwt(dl=True,init_del=True,final_del=True,clean=True):

    # get current directory
    dstpth = os.path.join('temp')
    if not os.path.exists(dstpth):
        os.makedirs(dstpth)
    os.chdir(dstpth)

    # Remove the existing directory if it exists
    suffix = "release"
    dirname = 'MODFLOW-NWT-%s'%suffix
    if os.path.isdir(dirname) and init_del:
        shutil.rmtree(dirname)

    # Download the MODFLOW-NWT distribution
    url = "https://github.com/gyanz/MODFLOW-NWT/archive/%s.zip"%suffix

    if dl:
        try:
            download_and_unzip(url)
        except:
            print(traceback.print_exc())
            return None
            

    # Remove the parallel and serial folders from the source directory
    srcdir = os.path.join(dirname,'src')
    target = 'mfnwt'


    try:
        pymake.main(srcdir, target, 'gfortran', 'gcc', makeclean=clean,
                    expedite=False, dryrun=False, double=False, debug=False,
                    fflags='cpp ffpe-summary=overflow DSWR_OUTER_1 DRIP_ET')

        # Clean up
        if os.path.isdir(dirname) and final_del:
            shutil.rmtree(dirname)

    except:
        print(traceback.print_exc())
        return None
    
    if sys.platform == 'win32':
        try:
            assert os.path.isfile(target), 'Target does not exist.'
        except:
            if not '.' in target:
                target = target + '.exe'
            
    assert os.path.isfile(target), 'Target %s does not exist.'%target
    

if __name__ == "__main__":
    args = sys.argv
    dl = 1   #download flag 
    init_del = 1 # delete initial files
    final_del = 1 # delete 
    clean = 0 # clean make
    arg_list = [dl,init_del,final_del,clean]
    for i,arg in enumerate(args[1:]):
        if int(arg) == 0:
            arg_list[i] = int(arg)
    print('console arguments: %r'%arg_list)
                
    make_mfnwt(arg_list[0],arg_list[1],arg_list[2],arg_list[3])
