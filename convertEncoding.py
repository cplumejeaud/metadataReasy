# coding: utf8
from __future__ import unicode_literals
#import encodings
#import chardet
import ConfigParser
import logging
import os, sys, traceback
from stat import *

class ConvertEncoding (object):

    def __init__(self, config):
        ## Ouvrir le fichier de log
        logging.basicConfig(filename=config.get('log', 'file'), level=int(config.get('log', 'level')), filemode='w')
        self.logger = logging.getLogger('convertEncoding')
        self.logger.debug('log file for DEBUG')
        self.logger.info('log file for INFO')
        self.logger.warning('log file for WARNINGS')
        self.logger.error('log file for ERROR')
        self.export_dir = config.get('xml', 'export_dir')


    def walktree(self, top, callback):
        '''
        recursively descend the directory tree rooted at top,
           calling the callback function for each regular file
           Aim is to find xml (.xml)
        exemple de call : self.walktree(rootdir, self.do_one_file)
        '''

        for f in os.listdir(top):
            pathname = os.path.join(top, f)
            mode = os.stat(pathname)[ST_MODE]
            if S_ISDIR(mode):
                # It's a directory, recurse into it
                self.walktree(pathname, callback)
            elif S_ISREG(mode):
                # It's a file, call the callback function
                callback(pathname)
            else:
                # Unknown file type, print a message
                #print 'Skipping %s' % pathname
                self.logger.warn('Skipping %s' % pathname)

    def do_one_file(self, filename):
        '''
        check if it is a XML file : if YES, try to parse it
        exemple de call : self.walktree(rootdir, self.do_one_file)
        '''
        print 'visiting', filename
        if (filename.endswith('.xml')):
            shortname = os.path.basename(filename)
            print 'shortname :', shortname
            self.convert_by_replacing_infile(filename)
            self.logger.debug('File processed %s' % filename)

    def convert_by_replacing_infile(self, src_file) :
        '''
        Les fichiers sources XML produits par le programme R (geometa) sont encodés en UTF_8 mais
        la fonction encode() gère mal les accents du latin 1 qui ne sont pas conséquents pas transformés.
        Cette fonction cherche un par un tous les patrons des lettres accentuées et les remplace
        par l'accent correspondant (Pour un listing plus complet : http://www.i18nqa.com/debug/utf8-debug.html)
        Lire aussi : http://sametmax.com/lencoding-en-python-une-bonne-fois-pour-toute/
        :param src_file: Fichier XML à transformer
        '''

        #a = "UniversitÃƒÂ©"
        #a.replace(u'ÃƒÂ©', u'é')

        target_file = os.path.join(self.export_dir, os.path.basename(src_file))
        fic = open(src_file, 'r')
        fic2 = open(target_file, 'w')

        for line in fic:
            l = line.decode('utf-8').replace('ÃƒÂ©', 'é')
            l = l.replace('ÃƒÂ¨', 'è')
            l = l.replace('Ã¢â‚¬â„¢', '\'') #Ã¢â‚¬â„¢
            l = l.replace('ÃƒÂ§', 'ç')
            l = l.replace('ÃƒÂª', 'ê') #ÃƒÂª

            l = l.replace('ÃƒÂ¹', 'ù')
            l = l.replace('ÃƒÂ®', 'î')
            l = l.replace('ÃƒÂ´', 'ô')

            l = l.replace('ÃƒÂ¢', 'â')
            l = l.replace('ÃƒÂ»', 'û')
            l = l.replace('ÃƒÂ¯', 'ï')
            l = l.replace('ÃƒÂ«', 'ë')
            l = l.replace('ÃƒÂ¶', 'ö')
            l = l.replace('ÃƒÂ¼', 'ü')

            l = l.replace('ÃƒÂ', 'à')

            l = l.replace('Ã©', 'é')
            l = l.replace('Â¨', 'è')
            l = l.replace('Ã', 'à')

            l = l.encode('utf-8')
            #print l
            fic2.write(l)
        fic.close()
        fic2.close()

if __name__ == '__main__':


    #Passer en parametre le nom du répertoire contenant le fichier de paramètre
    #configfile = sys.argv[1]
    configfile = 'config_convert.txt'
    config = ConfigParser.RawConfigParser()
    config.read(configfile)

    print("Fichier de LOGS : "+config.get('log', 'file'))

    u = ConvertEncoding(config)
    u.walktree(config.get('xml', 'src_dir'), u.do_one_file)

