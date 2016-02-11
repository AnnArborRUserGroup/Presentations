# -*- coding: utf-8 -*-
"""
gensim: Python API for word2vec
"""

import gensim

#%%
model = gensim.models.Word2Vec.load_word2vec_format('H:/Documents/DataGovRes/research/lyricsNLP/lyrics.bin', binary=True)

#%%
model.most_similar(positive=['shadow'],negative=['shrouding'],topn=10) #46&2

#%%
model.most_similar(positive=['pieces','fit'],topn=10) #Schism

#%%
model.most_similar(positive=['sober'],topn=10) #Sober