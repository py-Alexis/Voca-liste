import re


# -------------------------------------
# ------------ CHECK WORD -------------
# -------------------------------------

def api_list_possible(answer):
    # create from an answer a list a word that could have been written by the user
    possible_answers = [answer]

    for element in ["", "the ", "le ", "la ", "du ", "de ", "les ", "l'", "d'"]:
        if element in answer:
            possible_good_answer = re.sub(element, "", answer)

            possible_answers += remove_space(re.sub("[\[].*?[\]]", "", possible_good_answer))
            if "(" in possible_good_answer:
                # remove brackets
                possible_answers += remove_space(re.sub("[\[].*?[\]]", "", possible_good_answer))
            if "[" in possible_good_answer:
                # remove square brackets
                possible_answers += remove_space(re.sub("[\(].*?[\)]", "", possible_good_answer))
            if "(" and "[" in possible_good_answer:
                # remove both
                possible_answers += remove_space(re.sub("[\(\[].*?[\)\]]", "", possible_good_answer))
    return possible_answers


def remove_space(word):
    # return [word, word without spaces at the end and at the begging, and word without all spaces]

    return [word, word.strip(), word.replace(" ", "")]

# ---------- END CHECK WORD -----------
