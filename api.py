import re


# -------------------------------------
# ------------ CHECK WORD -------------
# -------------------------------------

def api_list_possible(answer):
    # create from an answer a list a word that could have been written by the user

    possible_answers = []

    for split_answer in answer.split("/"):

        for element in ["", "the ", "le ", "la ", "du ", "de ", "les ", "l'", "d'", "un", "une"]:

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