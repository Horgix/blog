+++
type = "post"
author = "Horgix"
date = "2019-08-08"
title = "Python, unittest, parameterized and a traceback walk into a bar"
description = ""
categories = ["python", "unittest", "testing", "wtf"]
+++


# Basics

We'll talk about:

- **Python** 3.7
- `unittest`, which is the built-in library for unit testing in Python
- [`parameterized`](TODO link), a library that makes it possible to create
  parameterized unit tests for unittest

# Hey, what if we had a nice output ?


# More generic problem

- External module fetched with `pip`. Let's call it **`foobar`**
- This `foobar` module contains two files: `__init__.py` and `foobar.py`
- The `__init__.py` contains nothing but `from .foobar import foobar`
- The `foobar.py` file contains the definition of a `class foobar` and also a
  global variable called `awesome_var` which value is `42`

Here's the catch: let's say we are coding something that uses this `foobar`
module. How do you go about accessingg `awesome_var`? Sounds simple, doesn't
it?

# The actual usecase

- `parameterized` module
- `unittest` and traceback hiding.

`__unittest`

# Traceback: go home parameterized, you're drunk

Hey, @joraf toi qui a bien bouffé du python.
J'ai un module externe chopé via pip qui s'appelle foobar. Il contient un __init__.py et un foobar.py. Le __init__.py fait que from .foobar import foobar
J'ai besoin d'accéder et redéfinir une  var globale dans foobar.py qui s'appelle lolvar, depuis mon code qui utilise cette lib. Comment tu t'y prendrais ?
import foobar
foobar.lolvar
March pas.
from foobar import  foobar
foobar.lolvar
Non plus.
Une idée ?
en pratique, mon code c'est des TU, le module externe c'est parameterized qui me sert à générer des unittest paramétrisés, et j'ai besoin de lui définir __unittest = True pour que unittest me masque sa traceback dans mes résultats de test (CF https://github.com/python/cpython/blob/c4cacc8c5eab50db8da3140353596f38a01115ca/Lib/unittest/result.py#L203) (edited)




y'a pas un foobar.foobar dans le coin ?
le module s'appelle foobar, genre :
foobar/
 __init__.py
 foobar.py
?
Alexis "Horgix" Chotard 15:52
yep
Jonathan Raffre 15:52
vu que le 2e fait from .foobar import foobar, t'as un foobar.foobar.lolvar probablement
et vu que le __init__ l'importe avant
tu dois pouvoir le modif en y accédant depuis l'import toplevel
Alexis "Horgix" Chotard 15:53
eh non
Jonathan Raffre 15:53
wut
Alexis "Horgix" Chotard 15:53
parce que dans foobar.py, t'as une class foobar
Jonathan Raffre 15:53
ah.
Alexis "Horgix" Chotard 15:53
du coup, foobar.foobar fait référence à la class foobar et non au module/file foobar.py :disappointed:
vu que __init__.py fait un from .foobar import foobar
Jonathan Raffre 15:53
wtf....
ok
Alexis "Horgix" Chotard 15:54
t'as donc une class foobar dans __init__.py, donc foobar.foobar = cette class et non pas le module T-T
enfin, c'est ce que j'en déduis de mes tests...
Jonathan Raffre 15:54
import foobar.foobar
foobar.foobar.lolvar = "blabla"
ça marche pas ?
Alexis "Horgix" Chotard 15:58
ModuleNotFoundError: No module named 'foobar.foobar.lolvar'; 'parameterized.parameterized' is not a package
Jonathan Raffre 15:59
jvais voir ce putain de module
c'est weird ce truc
Alexis "Horgix" Chotard 16:00
https://github.com/wolever/parameterized/tree/master/parameterized


https://github.com/wolever/parameterized/tree/master/parameterized
