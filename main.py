# This Python file uses the following encoding: utf-8
import datetime
import glob
import json
import os
import random
import shutil
import sys
import time
import webbrowser

from api.api import api_list_possible

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
        # Function that read the content of json file
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
        # Function that write the "content" in a json file
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
        # Function that calculates the general level of a list

        # If the name of the list is not specified it calculates the level of the list stored in wordList
        if not liste_name:
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
    def get_words(self, list_name, new_line=False):
        # Send the list of word in the list call "listName"
        #
        # When we click on newLine button in the modify page it destroy the table create a new line and recreate the
        # table but this time since new_line is set to True it automatically scroll down and select the new line

        content_list = self.read(list_name)

        self.sendWordList.emit(content_list["liste"], new_line)
        self.sendHistory.emit(self.get_history(list_name))

    def get_history(self, liste):
        # return the history of the list (but just the important parts)
        # [[date, lvString, timeSpent, nbMistake, mistakes, lvNumber],
        # ['23 Jul 2021\n18 : 51', '50.0% -> 33.3%', '00:09', 4, 'mistake1 mistake2 mistake3 mistake4', 33.3] ...]

        content_liste = self.read(liste)

        formatted_history = []

        for index, element in enumerate(content_liste["historique"]):
            # date format
            formatted_history.append([datetime.datetime.fromtimestamp(element[0]).strftime('%d %b %G\n%H : %M')])

            if index == 0:
                formatted_history[0].append(f"0% -> {element[2]}%")
            else:
                formatted_history[index].append(f"{content_liste['historique'][index - 1][2]}% -> {element[2]}%")

            formatted_history[index].append(f"{format(int(element[4] // 60), '02d')}:{format(int(element[4] % 60), '02d')}")

            formatted_history[index].append(len(element[3]))

            mistakes = ""
            for mistake in element[3]:
                mistakes += mistake[0]
                mistakes += " "

            formatted_history[index].append(mistakes)
            formatted_history[index].append(element[2])
            formatted_history[index].append(element[5])
            formatted_history[index].append(element[6])

        return formatted_history

    # --------END GENERAL FUNCTION---------

    sendCloseAsk = Signal()
    @Slot()
    def close_ask(self):
        # Ask the current Page if it's ok to close (ex: for the modify page if you close you lose the modification)
        self.sendCloseAsk.emit()

    sendClose = Signal()
    @Slot()
    def close(self):
        self.sendClose.emit()

    sendThemeList = Signal(list, str)
    def theme_list(self):
        # sends the list of themes to fill the tapBar in the settings panel

        content_settings = self.read(path=settings_path)

        self.sendThemeList.emit(content_settings["Theme List"], content_settings["Active Theme"])

    sendTheme = Signal("QVariant")
    def get_theme(self):
        # Send the color theme to main.qml

        content_settings = self.read(path=settings_path)
        content_theme = self.read(path="Settings/Theme/" + content_settings["Active Theme"] + "_theme.json")

        self.sendTheme.emit(content_theme)
        # It first look at the current theme in the settings file and then open the corresponding file to send it's
        # content to main.qml

    @Slot(str)
    def change_theme(self, theme):
        # change the theme just by changing the active theme in the setting.json file and then call get theme to send
        # the colors to main.qml

        content_settings = self.read(path=settings_path)
        content_settings["Active Theme"] = theme
        self.write(content_settings, path=settings_path)

        self.get_theme()

    initializeCustomTopBar = Signal(bool)
    def get_custom_top_bar(self):
        # send to main.qml file the status of the custom top bar so that it stays the same when you close the app

        content_settings = self.read(path=settings_path)
        self.initializeCustomTopBar.emit(content_settings["Custom Top Bar"])

    sendCustomTopBar = Signal(bool)
    @Slot(bool)
    def switch_top_bar(self, state):
        # Switch custom top bar status

        # Change the status of the custom top bar so that the app remembers it when you close it
        content_settings = self.read(path=settings_path)
        content_settings["Custom Top Bar"] = not state
        self.write(content_settings, path=settings_path)

        self.sendCustomTopBar.emit(not state)

    initializeStackViewAnimation = Signal(bool)
    def get_stack_view_animation(self):
        # send to main.qml file the status of the stack view animation so that it stays the same when you close the app

        content_settings = self.read(path=settings_path)
        self.initializeStackViewAnimation.emit(content_settings["StackView animation"])

    @Slot(bool)
    def toggle_stack_view_animation(self, state):
        # Change the status of the stack view animation so that the app remembers it when you close it

        content_settings = self.read(path=settings_path)
        content_settings["StackView animation"] = state
        self.write(content_settings, path=settings_path)

    @Slot()
    def open_github(self):
        webbrowser.open('https://github.com/py-Alexis/voca-liste', new=2)

    # -------------------------------------
    # --------------HOME PAGE--------------
    # -------------------------------------

    sendListList = Signal("QVariant")
    @Slot()
    def get_list_list(self):
        # sends a dictionary of all lists (and listMode) sorted by category
        #       {"category 1": [["list 1", listMode], ["list 2", listMode], ["list 3", listMode]],
        #        "category 2": [["list 6", listMode], ["list 4", listMode]]}

        list_file = os.listdir("listes")  # get the list of json file
        list_category = {}

        for file in list_file:

            content_list = self.read(path="listes/" + file)

            if content_list["catégorie"] in list_category:  # if the category is in the dictionary append the list
                list_category[content_list["catégorie"]].append([file.replace(".json", ""), content_list["mode"]])

            else:  # if the category don't exist in the dictionary create it in the dictionary with the list
                list_category[content_list["catégorie"]] = [[file.replace(".json", ""), content_list["mode"]]]

        self.sendListList.emit(list_category)  # send the dictionary to qml file "HomePage.qml"

    @Slot("QVariant")
    def import_liste(self, list_urls):
        # when the user wants to import lists an explorer window opens for him to choose.
        # when it validates this function checks that the selected files do not exist

        for url in list_urls:
            path = str(url)[29:-2]  # Urls given by the explorer dialog are a bit weird so I have to remove some chars

            if os.path.isfile("listes/" + os.path.basename(path)):
                pass
            else:
                shutil.copy2(path, "listes")

    sendCheckedName = Signal(str)
    sendNewFile = Signal()
    @Slot(str)
    def check_name(self, name):
        # when the user creates a new list he has to choose its name but as it is the name of a file it has to
        # respect some standard (it must not already exist and must not contain certain characters)

        forbidden_char = ["|", "/", "\\", ".", "<", ">", ":", "\"", "?", "*"]
        for char in forbidden_char:
            if char in name:
                self.sendCheckedName.emit("charatere invalide")
                return False

        if os.path.isfile("listes/" + name + ".json"):
            self.sendCheckedName.emit("existe déjà")
            return False

        content_list = self.read(path="settings/template_list.json")

        self.write(content_list, name)

        self.create_backup(name)

        self.sendCheckedName.emit(name)
        self.sendNewFile.emit()

    @Slot(str)
    def del_file(self, liste_name):
        os.remove("listes/" + liste_name + ".json")

    # ------------FIN HOME PAGE------------

    # -------------------------------------
    # --------------  Modify  -------------
    # -------------------------------------

    def create_backup(self, liste_name):

        # delete files in backup folder
        if len(os.listdir('Settings/Backup')) != 0:
            files = glob.glob("Settings/Backup/*")
            for f in files:
                os.remove(f)

        # create a backup of the file
        shutil.copy2(f"listes/{liste_name}.json", f"settings/Backup/{liste_name}_backup.json")

    sendCreateTable = Signal(str)
    @Slot(str)
    def create_table(self, liste):
        # backup the file so we can cancel the modification and send the category of the list
        self.create_backup(liste)

        content_list = self.read(liste)

        if content_list["catégorie"] == "None":
            self.sendCreateTable.emit("")
        else:
            self.sendCreateTable.emit(content_list["catégorie"])

    @Slot()
    def get_backup(self):
        # restore the changes (when the user cancels or closes) by deleting the file and copying the backup file

        # Get the name of the list (settings/Backup/{list}_backup.json) in the backup folder
        old_list_name = os.path.basename(glob.glob("Settings/Backup/*")[0])[:-12]

        # Remove the list
        os.remove(f"listes/{old_list_name}.json")

        # Copy back the backup
        shutil.copy2(f"settings/Backup/{old_list_name}_backup.json", f"listes/{old_list_name}.json")

    @Slot(str, int, int, str)
    def update_word(self, liste, row, column, word):
        # when a cell is modified the word is updated in the list file

        content_list = self.read(liste)

        content_list["liste"][row][column] = word

        self.write(content_list, liste)

    @Slot(str)
    def new_line(self, liste):
        # When newLine button is pressed it destroy the table, and call this function
        # the function just create a new line in the list of words
        # and call the get words function to recreate the table but with the argument newLine set to True so it scroll
        # down to the newLine and it focus the first cell of that line

        content_list = self.read(liste)

        content_list["liste"].append(["", "", "", -1])

        self.write(content_list, liste)

        self.get_words(liste, new_line=True)

    sendNewLineOnEnter = Signal()
    @Slot()
    def new_line_on_enter(self):
        self.sendNewLineOnEnter.emit()

    getCurrentRow = Signal(str)
    @Slot(str, int)
    def del_line(self, liste, selected_row):
        # delete the selected_row in the list file
        # When the user click on the supp button it destroy the table, call this function but this part of the qml
        # don't know which cell is selected so it call the function with the argument selected Row to -2

        if selected_row == -2:
            # If selected_row is equal to -2 it means that we don't know which cell is selected
            # so we ask with the get CurrentRow Signal that will recall this function with the correct selected row

            self.getCurrentRow.emit("suppLine")

        elif selected_row == -1:
            # if no row is selected it selected_row is equal to -1 and we just recreate the table

            self.get_words(liste)

        else:
            # if a row is selected it delete it
            content_list = self.read(liste)

            del content_list["liste"][selected_row]

            self.write(content_list, liste)

            # and then recreate the table
            self.get_words(liste)

    checkedList = Signal(str)
    @Slot(str, str)
    def check_list(self, liste, new_list_name):
        # when save button is pressed this function checks if all lines are filled (at least the 2 first cells),
        # check the list name and check for duplicate words or definitions

        content_list = self.read(liste)

        # check if every line
        index = 1
        for element in content_list["liste"]:
            if element[0].strip() == "" or element[1].strip() == "":
                self.checkedList.emit(f"la ligne {index} n'est pas complète")
                return False

            index += 1

        # check for duplicate words or definitions
        liste_word = [i[1] for i in content_list["liste"]]
        liste_def = [i[0] for i in content_list["liste"]]
        if len(liste_def) != len(set(liste_def)):
            self.checkedList.emit("deux mots/expressions sont identiques")
            return False
        elif len(liste_word) != (len(set(liste_word))):
            self.checkedList.emit("deux définitions/traductions sont identiques")
            return False

        # check if the file name is not empty
        if new_list_name == "":
            self.checkedList.emit("le nom de la liste ne peut pas être vide")
            return False

        # check if the file already exist
        elif os.path.isfile("listes/" + new_list_name + ".json") and liste != new_list_name:
            self.checkedList.emit("le nom de la liste existe déjà")
            return False

        # if the name of the list is correct it renames it
        os.rename("listes/" + liste + ".json", "listes/" + new_list_name + ".json")

        self.checkedList.emit("ok")  # the file is complete (so it can go back to home page)
        self.get_list_list()  # create the elements of the homepage

    @Slot(str, int)
    def reset_lv(self, liste, selected_row):
        # when the reset level button is pressed we reset the level of the selected row
        # Here it's the same trick than in del_line function to get the selected row

        if selected_row == -2:
            self.getCurrentRow.emit("resetLv")

        elif selected_row == -1:
            self.get_words(liste)

        else:
            content_list = self.read(liste)

            content_list["liste"][selected_row][3] = -1

            self.write(content_list, liste)

            self.get_words(liste)

    @Slot(str, str)
    def change_mode(self, liste, mode):
        # change the mode of "liste" to "mode"

        content_list = self.read(liste)

        content_list["mode"] = mode

        self.write(content_list, liste)

    @Slot(str, str)
    def update_category(self, liste, category):
        # update the category of "liste" with the value "category" whenever the user changes it in modify page
        # if the category textInput is empty the value return in the list file is "None"

        if category == "":
            category = "None"

        content_list = self.read(liste)

        content_list["catégorie"] = category

        self.write(content_list, liste)

    # ------------  FIN Modify  -----------

    # -------------------------------------
    # ---------  Revision Selector  -------
    # -------------------------------------

    # It was (int, int, "QVariant") but it was crashing from time to time so I put them all in a list
    sendListInfo = Signal("QVariant")
    @Slot(str)
    def get_list_info(self, liste):
        # Send list info: number of word in the list and general level of the list
        content_liste = self.read(liste)

        nb_word = len(content_liste["liste"])

        self.sendListInfo.emit([nb_word, self.get_list_percentage(liste), self.get_history(liste)])

    # -------  Fin Revision Selector ------

    # -------------------------------------
    # -----------  Revision Page  ---------
    # -------------------------------------

    initializeRevision = Signal(list)   # [str, str, int] same problem as with get_list_info
    @Slot(str, str, str)
    def start_revision(self, liste, revision_mode, revision_direction):
        # Initialize revision Page and history
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

        next_word_info = {"displayWord": "", "toFindWord": "", "context": False, "hint": [], "current_direction": ""}

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

    send_checked_answer = Signal(bool)
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

        self.send_checked_answer.emit(result)

    @Slot(int)
    def was_right(self, index):
        # triggers when I was right btn is clicked
        # update the word level

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
        # triggers when an answer is clicked in the qcm mode
        # updates the word level and if the answer is wrong adds it to the history

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

    # I don't know why but without it there are errors.
    app.setOrganizationName("Alexis MORICE")
    app.setOrganizationDomain("j'ai_pas_de_site.com")
    app.setApplicationName("voca-liste")

    main = MainWindow()
    engine.rootContext().setContextProperty("backend", main)

    # Load QML File
    engine.load(os.path.join(os.path.dirname(__file__), "qml/main.qml"))

    # Initialize
    main.theme_list()
    main.get_theme()
    main.get_custom_top_bar()
    main.get_stack_view_animation()
    main.get_list_list()

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
