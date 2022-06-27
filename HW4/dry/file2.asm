.global get_function

.text
get_function:
    movq $get_password, get_password_function
    ret
