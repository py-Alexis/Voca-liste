import re
from random import shuffle
import json
from pprint import pprint

# -------------------------------------
# ------------ CHECK WORD -------------
# -------------------------------------


def api_list_possible(answer):
    # create from an answer a list a word that could have been written by the user

    possible_answers = []

    for split_answer in answer.split("/"):

        for element in ["", "the ", "a ", "le ", "la ", "du ", "de ", "les ", "l'", "d'", "un", "une"]:

            if element in split_answer:
                possible_good_answer = re.sub(element, "", split_answer)
                possible_answers += remove_space(possible_good_answer)

                if "[" in possible_good_answer:
                    # remove brackets
                    possible_answers += remove_space(re.sub("[\[].*?[\]]", "", possible_good_answer))
                if "(" in possible_good_answer:
                    # remove square brackets
                    possible_answers += remove_space(re.sub("[\(].*?[\)]", "", possible_good_answer))
                if "(" and "[" in possible_good_answer:
                    # remove both
                    possible_answers += remove_space(re.sub("[\(\[].*?[\)\]]", "", possible_good_answer))

    return possible_answers


def remove_space(word):
    print(word)
    # return [word, word without spaces at the end and at the begging, and word without all spaces]

    return [word, word.strip(), word.replace(" ", "")]


# ---------- END CHECK WORD -----------

def revise_last(history, word_liste):
    last = history[-1]
    word_liste_noLv = []
    word_liste_final = []

    # if last element of the history is a list => last revision was on a part of the list
    if type(last[-1]) == list:

        # the list of word may have a different level so I remove the levels
        for element in word_liste:
            word_liste_noLv.append(element[:-1])

        for element in last[-1]:
            if element[:-1] in word_liste_noLv:
                word_liste_final.append(word_liste[word_liste_noLv.index(element[:-1])])

        return word_liste_final

    # if last element is not a list => last revision was on the whole list => return all the words
    else:
        return word_liste


def list_word_lv(word_list, lv):
    # this function return the list of word with the level "lv"
    word_list_final = []

    for element in word_list:
        if element[-1] == lv:
            word_list_final.append(element)

    return word_list_final


def revise_part_of_list(word_list, n):
    # this function returns the n words of the list that the user knows the least
    word_list_final = []
    lv = -1

    while len(word_list_final) < n and lv <= 7:
        word_list_lv = list_word_lv(word_list, lv)

        if n - len(word_list_final) < len(word_list_lv):
            shuffle(word_list_lv)
            word_list_final += word_list_lv[:n - len(word_list_final)]
        else:
            word_list_final += word_list_lv

        lv += 1
        print(lv)
    return word_list_final


if __name__ == "__main__":
    with open("D:\perso\Dev\python\projets/09_voca_list/voca-liste\listes\liste de test.json", "r", encoding="utf-8") as f:
        liste_content = json.load(f)

    variable = revise_last(liste_content["historique"],liste_content["liste"])
    pprint(variable)
    print(len(variable))



