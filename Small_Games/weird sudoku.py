# -*- coding: utf-8 -*-
"""
Created on Thu Dec 14 14:38:05 2023

@author: Le Cornec
"""


import pandas
import openpyxl
# import tkinter as tk
from tkinter import ttk, Tk, Button, Label, IntVar, Checkbutton
from tkinter import *
import xlrd
from openpyxl import load_workbook
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt
from random import randint
import time
from copy import deepcopy

max_dur=3
start_time=time.time()

def verify():
    pass

def close_window():
    root.destroy()  
    

def initialization():
    global events, variables, root 
    
    root = Tk()
    root.attributes('-fullscreen', True)

    # root.geometry('800x400+500+300')
    root.title("Weird sudoku")
    root.resizable(True, True)
    root.configure(background="#808080")
    line1=[]
    line2=[]
    line3=[]
    line4=[]
    
    lines=[line1,line2,line3,line4]
  
    # while True:
    #     time_spent=time.time() - start_time
    #     if time_spent>max_dur:
    #         break
    for i in range(0,len(lines)):
        choices=[1,2,3,4]
        compteur=1
        while compteur!=0:
            a=randint(0,3)
            compteur=0
            for line in range(0,i):
                if lines[line][0]==choices[a-1]:
                    print(lines[line][0])
                    print("okkk")
                    compteur+=1
        
        lines[i].append(choices[a-1])
        choices.remove(choices[a-1])
        compteur=1
        while compteur!=0:
            b=randint(0,2)
            compteur=0
            for line in range(0,i):
                if lines[line][1]==choices[b-1]:
                    compteur+=1
        lines[i].append(choices[b-1])
        choices.remove(choices[b-1])
        compteur=1
        while compteur!=0:
            c=randint(0,1)
            compteur=0
            for line in range(0,i):
                if lines[line][2]==choices[c-1]:
                    compteur+=1
        lines[i].append(choices[c-1])
        choices.remove(choices[c-1])
        
        compteur=1
        while compteur!=0:
            d=0
            compteur=0
            for line in range(0,i):
                if lines[line][3]==choices[d-1]:
                    compteur+=1
       
        lines[i].append(choices[d])    

    
    colonnes = [list(colonne) for colonne in zip(*lines)]
            
    colonnes_signs=deepcopy(colonnes)
    lines_signs=deepcopy(lines)
    lines_hided=deepcopy(lines)
    
    for i in range(0,2):
        a = randint(0,1)

        if a==0:
            b=randint(1,3)
            c=randint(0,3)
            while type(lines_signs[c][b-1])!=int or type(lines_signs[c][b])!=int:
                b=randint(1,3)
                c=randint(0,3)
            if lines_signs[c][b-1]>lines_signs[c][b]:
                comp=">"
            else:
                comp="<"
            lines_signs[c].insert(b,comp)
        else:
            c=randint(0,3)
            b=randint(1,3)
            while type(colonnes_signs[c][b-1])!=int or type(colonnes_signs[c][b])!=int:
                b=randint(1,3)
                c=randint(0,3)
            if colonnes_signs[c][b-1]>colonnes_signs[c][b]:
                comp=">"
            else:
                comp="<"
            colonnes_signs[c].insert(b,comp)
            
    for i in range(0,19):
            b=randint(0,3)
            c=randint(0,3)
            lines_hided[c][b]="X"

    colonnes_hided = [list(colonne) for colonne in zip(*lines_hided)]
    
    
    
    # for line in lines_signs:
    #     for i in range(0, len(line)+1):
    #         if type(line[i])==int and type(line[i+1])==int:
    #             line.insert(i+1," ")
                
    # for col in colonnes_signs:
    #     for i in range(0, len(col)+1):
    #         if type(col[i])==int and type(col[i+1])==int:
    #             col.insert(i+1," ")
          
    print(lines)
    print(lines_signs)
    print(lines_hided)
    print(colonnes)
    print(colonnes_signs)
    print(colonnes_hided)
    
    
    
    y_axe=200
    for line in lines_hided:
        x_axe=400
        for i in line:
            if type(i)==int:
                    txtvariables = Label(root, borderwidth=0, relief=SUNKEN, text=str(i), font=("Sans serif", 24), background="#808080", foreground="black")
                    txtvariables.place(x=x_axe, y=y_axe)  
            else:
                    answers = ttk.Combobox(root,font=("Sans serif", 24), background="#808080", foreground="black")
                    answers['values']=[1,2,3,4]
                    answers.place(x=x_axe-10, y=y_axe, width=45)
            x_axe+=100
                
        y_axe+=100
        
    y_axe=200
    for line in lines_signs:
        x_axe=350
        for i in range (0,len(line)):
            if line[i]==">" or line[i]=="<":
                txtvariables = Label(root, borderwidth=0, relief=SUNKEN, text=str(line[i]), font=("Sans serif", 24), background="#808080", foreground="black")
                txtvariables.place(x=x_axe, y=y_axe) 
                x_axe-=100
            x_axe+=100
        y_axe+=100
        
        
        
    x_axe=400    
    for col in colonnes_signs:
        y_axe=150
        for i in range (0,len(col)):
            if col[i]==">" or col[i]=="<":
                if col[i]=='<':
                    txt='\u028C'
                else:
                    txt='V'

                txtvariables = Label(root, borderwidth=0, relief=SUNKEN, text=txt, font=("Sans serif", 24), background="#808080", foreground="black")
                txtvariables.place(x=x_axe, y=y_axe) 
                y_axe-=100
            y_axe+=100
        x_axe+=100
        
    
                
                
             
         
   
    
    lbltitre = Label(root, borderwidth=3, relief=SUNKEN, text="Place the correct numbers", font=("Sans serif", 25), background="#483088", foreground="white")
    lbltitre.place(x=480, y=0, width=600)
    
    
    
    
    close_button = Button(root, text="X", font=('ARIAL', 16), command=close_window)
    close_button.place(x=root.winfo_screenwidth() - 50, y=10, width=40, height=40)
    btnenregistrer = Button(root, text="Verify", font=('ARIAL', 16), bg='#483088', fg='white', command=verify)
    btnenregistrer.place(x=1200, y=200, width=200)
    
    root.mainloop()
    
initialization()
