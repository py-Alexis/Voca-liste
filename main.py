# This Python file uses the following encoding: utf-8
import datetime
import glob
import json
import os
import random
import shutil
import sys
import time

from api import api_list_possible

from PySide2.QtCore import QObject, Slot, Signal
from PySide2.QtGui import QGuiApplication, QIcon
from PySide2.QtQml import QQmlApplicationEngine

# General variable
settings_path = "Settings\\Settings.json"

# Global variable for Revision Page
word_list = []
word_list_shuffle = []
history = []
time_start = 0


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

    def get_list_percentage(self, liste_name=False):

        if liste_name == False:
            content_liste = word_list
        else:
            content_liste = self.read(liste_name)["liste"]

        nb_word = len(content_liste)
        lv_sum = 0

        for element in content_liste:
            if element[3] != -1:
                lv_sum += element[3]

        return round((lv_sum / (nb_word * 6)) * 100, 1)

    sendWordList = Signal("QVariant", bool)
    sendHistory = Signal("QVariant")
    @Slot(str)
    def getWords(self, listName, newLine=False):
        # Send the list of word in the list call "listName"
        #
        # When we click on newLine button in the modify page it destroy the table create a newLine and recreate the
        # table but this time since newLine is set to True it automatically scroll down and select the new line

        content_list = self.read(listName)

        self.sendWordList.emit(content_list["liste"], newLine)
        self.sendHistory.emit(self.get_history(listName))

    def get_history(self, liste):
        # return the history of the list (but just the important parts)
        # [[date, lvString, timeSpent, nbMistake, mistakes, lvNumber],
        # ['23 Jul 2021\n18 : 51', '50.0% -> 33.3%', '00:09', 4, 'mistake1 mistake2 mistake3 mistake4', 33.3] ...]

        content_liste = self.read(liste)

        history = []

        for index, element in enumerate(content_liste["historique"]):
            # date format
            history.append([datetime.datetime.fromtimestamp(element[0]).strftime('%d %b %G\n%H : %M')])

            if index == 0:
                history[0].append(f"0% -> {element[2]}%")
            else:
                history[index].append(f"{content_liste['historique'][index - 1][2]}% -> {element[2]}%")

            history[index].append(f"{format(int(element[4] // 60), '02d')}:{format(int(element[4] % 60), '02d')}")

            history[index].append(len(element[3]))

            mistakes = ""
            for mistake in element[3]:
                mistakes += mistake[0]
                mistakes += " "

            history[index].append(mistakes)
            history[index].append(element[2])
            history[index].append(element[5])
            history[index].append(element[6])

        return history

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
            path = str(url)[29:-2]  # Urls given by the dialog are a bit weird so we have to remove some chars

            if os.path.isfile("listes/" + os.path.basename(path)):
                pass  # ________________________________________________________________________________________________ajouter un popup à la fin qui dit que le fichier n'a pas pu être copier car il existe déjà
            else:
                shutil.copy2(path, "listes")

    sendCheckedName = Signal(str)
    sendNewFile = Signal()
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
            self.sendNewFile.emit()
            return True

        except:  # Not good to do a such large except but it shouldn't be necessary anyway so I just keep it like that
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
            if element[0].strip() == "" or element[1].strip() == "":
                self.checkedList.emit(f"la ligne {index} n'est pas complète")
                return False

            index += 1

        # check if there is duplicate word or definition
        liste_word = [i[1] for i in content_list["liste"]]
        liste_def = [i[0] for i in content_list["liste"]]
        if len(liste_def) != len(set(liste_def)):
            self.checkedList.emit("deux mots/expressions sont identiques")
            return False
        elif len(liste_word) != (len(set(liste_word))):
            self.checkedList.emit("deux définitions/traductions sont identiques")
            return False

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
        self.getListList()  # we create the elements of the homepage

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

    sendListInfo = Signal("QVariant") # if fact it int, int, "QVariant" but it crash sometimes so again all in a list
    @Slot(str)
    def getListInfo(self, liste):
        # Send list info: number of word in the list and percentage
        content_liste = self.read(liste)

        nb_word = len(content_liste["liste"])

        self.sendListInfo.emit([nb_word, self.get_list_percentage(liste), self.get_history(liste)])

    # -------  Fin Revision Selector ------

    # -------------------------------------
    # -----------  Revision Page  ---------
    # -------------------------------------

    initializeRevision = Signal(list) # [str, str, int] but for some reason it crash the app without them in list
    @Slot(str, str, str, str)
    def startRevision(self, liste, liste_mode, revision_mode, revision_direction):
        # Initialize revision Page
        #
        # revision_mode: "write" or "QCM"
        # revision_direction: "default" (definition => mot); "opposite" (mot => definition); "random"

        global time_start
        time_start = datetime.datetime.now()

        global word_list
        global word_list_shuffle
        word_list = self.read(liste)["liste"]
        word_list_shuffle = self.read(liste)["liste"]
        random.shuffle(word_list_shuffle)

        global history
        history = [time.time(), time.ctime(), -1, []]

        self.initializeRevision.emit([revision_mode, revision_direction, len(word_list)])

        self.next_word(revision_mode, revision_direction, 1)

    new_word = Signal("QVariant")
    @Slot(str, str, int)
    def next_word(self, revision_mode, revision_direction, index):
        # send the next word in the form of a dictionary:
        # {"displayWord" : "word", "toFindWord": "corresponding word", "context" : "if some context",
        # "hint" : ["word1", "word2", "word3_if_in_qcm_mode"], "current_direction" = "default"}
        index -= 1

        next_word_info = {"displayWord": "", "toFindWord": "", "context": False, "hint": [], "current_direction": "" }

        if revision_direction == "random":
            revision_direction = random.choice(["default", "opposite"])

        if revision_direction == "default":
            next_word_info["displayWord"] = word_list_shuffle[index][1]
            next_word_info["toFindWord"] = word_list_shuffle[index][0]
            next_word_info["current_direction"] = "default"
        else:
            next_word_info["displayWord"] = word_list_shuffle[index][0]
            next_word_info["toFindWord"] = word_list_shuffle[index][1]
            next_word_info["current_direction"] = "opposite"

        if word_list_shuffle[index][2] != "":
            next_word_info["context"] = word_list_shuffle[index][2]

        if revision_mode == "QCM":

            while len(next_word_info["hint"]) < 3:
                new_hint = random.choice(word_list_shuffle)

                # The hint can't be the word we are looking for
                if new_hint != word_list_shuffle[index]:

                    # check if the hint is already in the list
                    if revision_direction == "default":
                        if new_hint[0] not in next_word_info["hint"]:
                            next_word_info["hint"].append(new_hint[0])

                    else:
                        if new_hint[1] not in next_word_info["hint"]:
                            next_word_info["hint"].append(new_hint[1])

            next_word_info["hint"].append(next_word_info["toFindWord"])
            random.shuffle(next_word_info["hint"])

        self.new_word.emit(next_word_info)

    send_call_next_word = Signal()
    @Slot()
    def call_next_word(self):
        self.send_call_next_word.emit()

    send_checked_answer = Signal(bool, str) # result (bool), goodAnswer
    @Slot(str, int, str)
    def check_answer_write(self, answer, index, direction):
        # check if the answer the user type is correct (not taking into consideration the brackets etc.)

        direction = 0 if direction == "default" else 1

        real_index = word_list.index(word_list_shuffle[index - 1])

        # Create a list of possible answer
        good_answer = word_list_shuffle[index - 1][direction]
        possible_answer = api_list_possible(good_answer)

        # Good answer
        if answer.strip() in possible_answer:
            result = True
            if word_list[real_index][3] == -1:
                word_list[real_index][3] = 1
            elif 0 <= word_list[real_index][3] < 6:
                word_list[real_index][3] += 1

        # Wrong answer
        else:
            result = False
            history[3].append(word_list_shuffle[index - 1])

            if 1 <= word_list[real_index][3]:
                word_list[real_index][3] -= 1
            elif word_list[real_index][3] == -1:
                word_list[real_index][3] = 0

        self.send_checked_answer.emit(result, word_list_shuffle[index - 1][0])

    @Slot(int)
    def was_right(self, index):
        # triger when I was right btn is clicked

        original_list = list(word_list_shuffle[index - 1])

        if 1 <= original_list[3]:
            original_list[3] -= 1
        elif original_list[3] == -1:
            original_list[3] = 0

        real_index = word_list.index(original_list)

        del history[-1][-1]

        if word_list_shuffle[index - 1][3] == -1:
            word_list[real_index][3] = 1
        elif 0 <= word_list_shuffle[index - 1][3] < 6:
            word_list[real_index][3] = word_list_shuffle[index - 1][3] + 1
        else:
            word_list[real_index][3] = 6

    @Slot(str, str, int)
    def add_history(self, word_clicked, to_find, index):
        real_index = word_list.index(word_list_shuffle[index - 1])

        if word_clicked == to_find:
            if word_list[real_index][3] == -1:
                word_list[real_index][3] = 1
            elif 0 <= word_list[real_index][3] < 3:
                word_list[real_index][3] += 1
        else:
            history[3].append(word_list_shuffle[index - 1])
            if 1 <= word_list[real_index][3]:
                word_list[real_index][3] -= 1
            elif word_list[real_index][3] == -1:
                word_list[real_index][3] = 0

    intializeResult = Signal(list)
    @Slot(str, str, str)
    def finish(self, liste, revision_mode, revision_direction):
        # activate when user finish the revision

        # calculate time spend on the list
        time_spend = datetime.datetime.now().replace(microsecond=0) - time_start.replace(microsecond=0)

        # update the list (each word level and history)
        content_liste = self.read(liste)
        content_liste["liste"] = word_list
        history[2] = self.get_list_percentage()
        history.append(int(time_spend.total_seconds()))
        history.append(revision_mode)
        history.append(revision_direction)
        content_liste["historique"].append(history)
        self.write(content_liste, liste)

        # initialize resultPage
        result = f"{len(word_list) - len(history[3])} / {len(word_list)}"
        mistake = ""
        if len(history[3]) != 0:
            for element in history[3]:
                mistake += element[0]
                mistake += " "



        self.intializeResult.emit([revision_mode, revision_direction, result, f"{history[2]}%", str(time_spend), mistake])
        self.sendHistory.emit(self.get_history(liste))

    # ---------  End Revision Page --------


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine(parent=app)

    app.setWindowIcon(QIcon("images/icon_app_top.svg"))

    # don't realy know why but without this it raise an error so I include it
    app.setOrganizationName("Alexis MORICE")
    app.setOrganizationDomain("j'ai_pas_de_site.com")
    app.setApplicationName("voca-liste")

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
