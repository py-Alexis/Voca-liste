# This Python file uses the following encoding: utf-8
import sys
import os, shutil, glob

from PySide2.QtGui import QGuiApplication, QIcon
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtCore import QObject, Slot, Signal

import json

settings_path = "Settings\Settings.json"


class MainWindow(QObject):
    def __init__(self):
        QObject.__init__(self)

    # -------------------------------------
    # ----------GENERAL FUNCTION-----------
    # -------------------------------------

    def read(self, liste="./", path=""):
        # General function that read the content of json file
        # By default you enter the name of the list but you can enter another path

        if liste != "./":
            with open("listes/" + liste + ".json", "r", encoding="utf-8") as f:
                return json.load(f)

        elif path != "":
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)

        else:
            return False

    def write(self, content, liste="./", path=""):
        # General function that write the content of json file
        # By default you enter the name of the list but you can enter another path

        if liste != "./":
            with open("listes/" + liste + ".json", "w", encoding="utf-8") as f:
                json.dump(content, f, indent=4, ensure_ascii=False)
        elif path != "":
            with open(path, "w", encoding="utf-8") as f:
                json.dump(content, f, indent=4, ensure_ascii=False)
        else:
            return False


    sendWordList = Signal("QVariant", bool)
    @Slot(str)
    def getWords(self, listName, newLine=False):
        # Send the list of word in the list call "listName"
        #
        # When we click on newLine button in the modify page it destroy the table create a newLine and recreate the
        # table but this time since newLine is set to True it automatically scroll down and select the new line

        content_list = self.read(listName)

        self.sendWordList.emit(content_list["liste"], newLine)

    # --------END GENERAL FUNCTION---------

    sendCloseAsk = Signal()
    @Slot()
    def closeAsk(self):
        # Ask the current Page if it's ok to close (ex: for the modify page if you close you lose the modification)
        self.sendCloseAsk.emit()

    sendClose = Signal()
    @Slot()
    def close(self):
        self.sendClose.emit()

    sendThemeList = Signal(list, str)
    def themeList(self):
        # envoie la liste des thèmes pour remplir le tapBar

        content_settings = self.read(path=settings_path)

        self.sendThemeList.emit(content_settings["Theme List"], content_settings["Active Theme"])

    sendTheme = Signal("QVariant")
    def getTheme(self):
        # Send the color theme to main.qml

        content_settings = self.read(path=settings_path)
        content_theme = self.read(path="Settings/Theme/" + content_settings["Active Theme"] + "_theme.json")

        self.sendTheme.emit(content_theme)
        # It first look at the current theme in the settings file and then open the corresponding file to send it's
        # content to main.qml

    @Slot(str)
    def changeTheme(self, theme):
        # change the theme just by changing the active theme in the setting.json file and then call get theme to send
        # the colors to main.qml

        content_settings = self.read(path=settings_path)
        content_settings["Active Theme"] = theme
        self.write(content_settings, path=settings_path)

        self.getTheme()

    intializeCustomTopBar = Signal(bool)
    def getCustomTopBar(self):
        # Tell to the main.qml file if the status of the custom top bar at app start so it's has the same value
        # before and after you close the app (might be easier to do so with qt but don't know how it works and I wanted
        # to do some python)

        content_settings = self.read(path=settings_path)

        self.intializeCustomTopBar.emit(content_settings["Custom Top Bar"])

    sendCustomTopBar = Signal(bool)
    @Slot(bool)
    def switchTopBar(self, statut):
        # Switch custom top bar status
        self.sendCustomTopBar.emit(not statut)

        # Change the custom top bar status in settings file so the app remember the status when close
        content_settings = self.read(path=settings_path)
        content_settings["Custom Top Bar"] = not statut
        self.write(content_settings, path=settings_path)

    # -------------------------------------
    # --------------HOME PAGE--------------
    # -------------------------------------

    sendListList = Signal("QVariant")
    @Slot()
    def getListList(self):
        # send a dictionary of the category and they're corresponding list (and listMode)
        #       {"category 1": [["list 1", listMode], ["list 2", listMode], ["list 3", listMode]],
        #        "category 2": [["list 6", listMode], ["list 4", listMode]]}

        list_fichier = os.listdir("listes")  # get the list of json file
        listesCategorie = {}

        for fichier in list_fichier:

            # Can't just do self.read(fichier) cause fichier already has the .json file extension
            content_list = self.read(path="listes/" + fichier)

            if content_list["catégorie"] in listesCategorie:  # if the category is in the dictionary append the list
                listesCategorie[content_list["catégorie"]].append([fichier.replace(".json", ""), content_list["mode"]])

            else:  # if the category don't exist in the dictionary create it in the dictionary with the list
                listesCategorie[content_list["catégorie"]] = [[fichier.replace(".json", ""), content_list["mode"]]]

        self.sendListList.emit(listesCategorie)  # send the dictionary to qml file "HomePage.qml"

    @Slot("QVariant")
    def importListe(self, listurls):
        # When the import button in home page is pressed a explorer dialog open to chose the file to import onclick ok:
        # We check for each files if it already exist, if not we copy it in the listes folder

        for url in listurls:
            path = str(url)[29:-2] # Urls given by the dialog are a bit weird so we have to remove some chars

            if os.path.isfile("listes/" + os.path.basename(path)):
                pass  # ________________________________________________________________________________________________ajouter un popup à la fin qui dit que le fichier n'a pas pu être copier car il existe déjà
            else:
                shutil.copy2(path, "listes")


    sendCheckedName = Signal(str)
    @Slot(str)
    def checkName(self, name):
        # When the user click on New list button he has to chose the name of the list but since it's gonna be a file
        # name it has to respect some standard (the file don't exist and it don't contain forbidden chars

        forbidden_char = ["|", "/", "\\", ".", "<", ">", ":", "\"", "?", "*"]
        for char in forbidden_char:
            if char in name:
                self.sendCheckedName.emit("charatere invalide")
                return False

        if os.path.isfile("listes/" + name + ".json"):
            self.sendCheckedName.emit("existe déjà")
            return False

        try:
            content_list = self.read(path="settings/template_list.json")

            self.write(content_list, name)

            self.sendCheckedName.emit(name)
            return True

        except: # Not good the do a such large except but it shouldn't be necessary anyway so I just keep it like that
            self.sendCheckedName.emit("erreur")
            return False

    @Slot(str)
    def supprimer(self, listeName):
        os.remove("listes/" + listeName + ".json")

    # ------------FIN HOME PAGE------------

    # -------------------------------------
    # --------------  Modify  -------------
    # -------------------------------------

    sendCreateTable = Signal(str)
    @Slot(str)
    def createTable(self, list):
        # backup the file so we can cancel the modification and send the categorie of the list

        if len(os.listdir('Settings/Backup')) != 0:  # delete files in backup folder
            files = glob.glob("Settings/Backup/*")
            for f in files:
                os.remove(f)

        shutil.copy2(f"listes/{list}.json", f"settings/Backup/{list}_backup.json")  # create a backup of the file

        content_list = self.read(list)

        if content_list["catégorie"] == "None":
            self.sendCreateTable.emit("")
        else:
            self.sendCreateTable.emit(content_list["catégorie"])

    @Slot()
    def getBackup(self):
        # restore the file when the modification are cancel by deleting the file and copying the backup

        # Get the name of the list (settings/Backup/{list}_backup.json) in the backup folder
        old_list_name = os.path.basename(glob.glob("Settings/Backup/*")[0])[:-12]

        # Remove the list
        os.remove(f"listes/{old_list_name}.json")

        # Copy back the backup
        shutil.copy2(f"settings/Backup/{old_list_name}_backup.json", f"listes/{old_list_name}.json")

    @Slot(str, int, int, str)
    def updateWord(self, list, row, column, word):

        content_list = self.read(list)

        content_list["liste"][row][column] = word

        self.write(content_list, list)

    @Slot(str)
    def newLine(self, list):
        # When newLine button is pressed it destroy the table, and call this function
        # the function just create a new line in the list of words
        # and call the get words function to recreate the table but with the argument newLine set to True so it scroll
        # down to the newLine and it focus the first cell of that line

        content_list = self.read(list)

        content_list["liste"].append(["", "", "", -1])

        self.write(content_list, list)

        self.getWords(list, newLine=True)

    sendNewLineOnEnter = Signal()
    @Slot()
    def newLineOnEnter(self):
        self.sendNewLineOnEnter.emit()


    getCurrentRow = Signal(str)
    @Slot(str, int)
    def suppLine(self, list, selectedRow):
        # delete the selectedRow in the list file
        # When the user click on the supp button it destroy the table, call this function but this part of the qml
        # don't know whick cell is selected so it call the function with the argument selected Row to -2

        if selectedRow == -2:
            # If selectedRow is equal to -2 it means that we don't know which cell is selected
            # so we ask with the get CurrentRow Signal that will recall this function with the correct selected row

            self.getCurrentRow.emit("suppLine")


        elif selectedRow == -1:
            # if no row is selected it selectedRow is equal to -1 and we just recreate the table

            self.getWords(list)

        else:
            # if a row is selected it delete it
            content_list = self.read(list)

            del content_list["liste"][selectedRow]

            self.write(content_list, list)

            # and then recreate the table
            self.getWords(list)

    checkedList = Signal(str)
    @Slot(str, str)
    def checkList(self, liste, newlistename):
        # when save button is pressed we check if everything is fill (at least the 2 first cells) and check the listname

        content_list = self.read(liste)

        index = 1
        for element in content_list["liste"]:
            if element[0] == "" or element[1] == "":
                self.checkedList.emit(f"la ligne {index} n'est pas complète")
                return False

            index += 1

        # check if the file name is not empty
        if newlistename == "":
            self.checkedList.emit("le nom de la liste ne peut pas être vide")
            return False

        # check if the file already exist
        elif os.path.isfile("listes/" + newlistename + ".json") and liste != newlistename:
            self.checkedList.emit("le nom de la liste existe déjà")
            return False

        # so if the file name is ok it rename it
        os.rename("listes/" + liste + ".json", "listes/" + newlistename + ".json")

        self.checkedList.emit("ok")  # the file is complete (so it can go back to home page)
        self.getListList() # we create the elements of the homepage

    @Slot(str, int)
    def resetLv(self, liste, selectedRow):
        # when the reset level button is pressed we reset the level of the selected row
        # Here it's the same trick than in suppLine function to get the selected row

        if selectedRow == -2:
            self.getCurrentRow.emit("resetLv")

        elif selectedRow == -1:
            self.getWords(liste)

        else:
            content_list = self.read(liste)

            content_list["liste"][selectedRow][3] = -1

            self.write(content_list, liste)

            self.getWords(liste)

    @Slot(str, str)
    def changeMode(self, liste, mode):
        # change the mode of "liste" to "mode"
        content_list = self.read(liste)

        content_list["mode"] = mode

        self.write(content_list, liste)

    @Slot(str, str)
    def updateCategorie(self, liste, categorie):
        # update the category of the "liste" with the value "categorie" whenever the user change it in modify page
        # if the category textInput is empty the value return in the list file is "None"

        if categorie == "":
            categorie = "None"

        content_list = self.read(liste)

        content_list["catégorie"] = categorie

        self.write(content_list, liste)

    # ------------  FIN Modify  -----------

    # -------------------------------------
    # ---------  Revision Selector  -------
    # -------------------------------------

    sendListInfo = Signal(int, int)
    @Slot(str)
    def getListInfo(self, liste):
        # Send list info: number of word in the list and percentage
        content_liste = self.read(liste)

        nb_word = len(content_liste["liste"])
        lv_sum = 0

        for element in content_liste["liste"]:
            if element[3] != -1:
                lv_sum += element[3]

        self.sendListInfo.emit(nb_word, (lv_sum/(nb_word * 6)) * 100)

    # -------  Fin Revision Selector ------


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine(parent=app)

    app.setWindowIcon(QIcon("images/icon_app_top.svg"))

    # don't realy know why but without this it raise an error so I inculde it
    app.setOrganizationName("Alexis MORICE")
    app.setOrganizationDomain("j'ai_pas_de_site.com")
    app.setApplicationName("voca-list")


    main = MainWindow()
    engine.rootContext().setContextProperty("backend", main)

    # Load QML File
    engine.load(os.path.join(os.path.dirname(__file__), "qml/main.qml"))

    # Initialize
    main.themeList()
    main.getTheme()
    main.getCustomTopBar()
    main.getListList()

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
