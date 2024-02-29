# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""


import pandas
import sys
from subprocess import call
import tkinter as tk
from tkinter import messagebox
from tkinter import ttk, Tk
from tkinter import *
import xlrd
from openpyxl import load_workbook
from PIL import Image, ImageTk
import datetime

import datetime
import pandas
import subprocess
from tkinter import ttk, Tk
from tkinter import *
import openpyxl
import tkinter as tk
    
from tkinter import *
from tkinter import messagebox
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg




def display_plot():
        
        global variable, event, plotting_window,rats, regions, plt
        
        fichier_excel = 'C:/Users/Le Cornec/.spyder-py3/CharaPlots/charaTest_Copie.xlsx'

        classeur = openpyxl.load_workbook(fichier_excel)

        feuille = classeur['HPC']
        
        
        toggle_checkbox()
        
        
        if rats.get() not in ["Rat 1", "Rat 2", "Rat 3", "Rat 4"] or len(regions)==0:
            error(2)
            
            
        elif len(regions)>1 and variable in ["Amplitude", "Duration", "Frequency"]:
            error(3)
        else:
                plt.clf()
                
                
                
                print(rats.get(), regions)
                rat = ''.join(filter(str.isdigit, rats.get()))
        
                rat = int(rat)
                        
                print(rat)
            
                      
                
                x_axe=[]
                y_axe=[]
                
                
                total_x_axes=[]
                total_y_axes=[]
                
                last_row=5212 #Enter the last row of your excel sheet
                compteur=0
                if event=="Ripples":
                    type_event="rip"
                elif event=="Spindles":
                    type_event="spi"
                elif event=="Delta Waves":
                    type_event="del"
                
                for i in range(0,8): #from i equal 1 to last filled column
                    
                    if (feuille[1][i]).value=="Rat":
                        
                        col_rats=int(i)
                        
                    if (feuille[1][i]).value=="Date":
                        col_dates=int(i)
                        
                    if (feuille[1][i]).value=="Event_Type":
                        col_events=int(i)
                        
                    if (feuille[1][i]).value=="Bin":
                        col_bins=int(i)
                        
                    if (feuille[1][i]).value=="Ent":
                        col_ent=int(i)
                        
                    if (feuille[1][i]).value=="Dur":
                        col_dur=int(i)
                        
                    if (feuille[1][i]).value=="Amp":
                        col_amp=int(i)
                        
                    if (feuille[1][i]).value=="Frq":
                        col_frq=int(i)
             
                        
                if variable=="Count":
                    
                    
                    # if len(rats)==1 and len(regions)==1:
                    for region in regions:
                        
                            feuille = classeur[region]
                        
                            x_axe=[]
                            y_axe=[]
                    
                            for i in range(2,5212):
                                if (feuille[i][col_rats]).value==rat:
                                    if (feuille[i][col_events]).value==type_event:
                                        # if (feuille[i][col_dates]).value==actual_date:
                                            actual_date=(feuille[i][col_dates]).value
                                            break
                                       
                            print(actual_date)
                    
                            # actual_date=(feuille[2][col_dates]).value
                            for i in range(2,5212):
                                if (feuille[i][col_rats]).value==rat:
                                    if (feuille[i][col_events]).value==type_event:
                                        if (feuille[i][col_dates]).value==actual_date: # not in x_axe:
                                        # x_axe.append((feuille[i][col_dates]).value)
                                    # while (feuille[i][col_rats]).value==rat:
                                            compteur+=1
                                        # print((feuille[i][col_dates]).value)
                                        # print("iji")
                                        # print(x_axe[-1])
                                       
                                        else: 
                                            y_axe.append(compteur)
                                            x_axe.append(str(actual_date))
                                            actual_date=(feuille[i][col_dates]).value
                                            compteur=1
                                           
                    
                                           
                              
                
                                        # if (feuille[i][col_dates]).value != x_axe[-1]:
                                        #      print("ok")
                                        # if (feuille[i][col_dates]).value not in x_axe: 
                                            
                                            # x_axe.append((feuille[i][col_dates]).value)
                                            # compteur=0
                                # i+=1
                                               
                                    # break
                                 
                            y_axe.append(compteur)
                            x_axe.append(str(actual_date)  )  
                            total_x_axes.append(x_axe)
                            total_y_axes.append(y_axe)
                            compteur=1
                           
                    print(total_x_axes)
                    print(total_y_axes)
                    
                           
        
        
                        
                        
                elif variable in ["Amplitude", "Duration", "Frequency"]: 
                    
                    
                    if variable == "Amplitude":
                        col_variable = col_amp
                    elif variable == "Duration":
                        col_variable = col_dur
                    elif variable == "Frequency":
                        col_variable = col_freq
                    
                    total_y_axes = []  # Initialisez total_y_axes en dehors de la boucle pour toutes les dates
                    region_rank=-1
                    for region in regions:
                        region_rank+=1
                        x_axe = []
                        y_axe = []
                        is_new_date = False
                    
                        for i in range(2, 5213):
                            if feuille[i][col_rats].value == rat:
                                if feuille[i][col_events].value == type_event:
                                    actual_date = feuille[i+1][col_dates].value
                                    break
                        print(i,feuille[i][col_rats].value,  rat )
                        print(feuille[i][col_events].value,  type_event)
                        print(actual_date)
                    
                        index = 1
                        j = 0
                        for i in range(1, last_row):
                            is_new_date=False
                            if feuille[i][col_rats].value == rat:
                                if feuille[i][col_events].value == type_event:
                                    if feuille[i][col_dates].value==actual_date:
                                    # print(feuille[i][col_variable].value)
                                        y_axe.append(feuille[i][col_variable].value)
                                        x_axe.append(str(feuille[i][col_dates].value))
                                        # print(y_axe)
                                        index += 1
                            
                                    else:
                                        is_new_date=True
                                        if len(y_axe)>1:
                                            total_y_axes.append(y_axe.copy())
                    
                            
                            if is_new_date:
                                 y_axe = [feuille[i][col_variable].value]
                                 actual_date = feuille[i][col_dates].value
                        x_axe = sorted(list(set(x_axe)))
                        total_x_axes.append(x_axe)
                        total_y_axes.append(y_axe.copy())
                    
                          
                            
                        # total_y_axes=total_y_axes[2:]
    
    # Maintenant, total_y_axes contient toutes les données pour chaque date
    
                           
                
                    # print(len(total_x_axes[0]))
                    # print(len(total_y_axes[0]))   
        
        
                plt.figure(figsize=(11,7))
                # for i in range(0, len(total_x_axes)):
                #     plt.plot(total_x_axes[i], total_y_axes[i], label="Rat "+ str(rats[i]))
                if variable=="Count":
                    for i in range(0, len(total_x_axes)):
                        plt.plot(total_x_axes[i], total_y_axes[i], label=regions[i])
                else:
                    # for i in range(0, len(total_x_axes)):
                    print(total_x_axes, total_y_axes)
                    plt.boxplot(total_y_axes,labels=total_x_axes[region_rank])#, label="Rat "+ str(rats[i]))
                        # plt.boxplot([y_date1, y_date2, y_date3], labels=dates)
                 
        
                plt.xlabel('Dates')
                plt.ylabel(variable)
                plt.title(variable + " of "+ event + " for rat " + str(rat) + " in " + str(list(regions)))
                plt.legend()
                
        
                  # Afficher le graphique
                # plt.show()
                canvas = FigureCanvasTkAgg(plt.gcf(), master=plotting_window)
                canvas_widget = canvas.get_tk_widget()
                canvas_widget.pack()
                canvas_widget.place(x=150, y=225)
            

def toggle_checkbox():
    global  variable, checkbox_var_rats, checkbox_var_regions, checkbox_var_rat, checkbox_var_region, regions #checkbox_var_rat, checkbox_var_region
    # rats=[]
    regions=[]
        
    for region, var in checkbox_var_regions.items():
        if var.get() == 1:
            regions.append(region)
            
        
            
    
    for region, var in checkbox_var_regions.items():
        if var.get() == 0:
            regions=[item for item in regions if item!=var.get()]

    print(regions)
    


def launch_plot():
    global event, variable, root
    
    # print(events.get())
    # print(variables.get())
    if variables.get() not in ["Count","Amplitude","Duration", "Frequency"] or events.get() not in ["Ripples","Spindles","Delta Waves"]:
        error(1)
    event=events.get()
    variable=variables.get()
    root.destroy()
    plotting()
    # subprocess.Popen(["python", "tuveuxquoi.py", str(combo1.get()), str(reponse2.get()),str(reponse3.get())])  # Passer la valeur de reponse comme argument à mdp.py
    # root.destroy() 
    


# def valider():
#     #global reponse
#     subprocess.Popen(["python", "tuveuxquoi.py", str(combo1.get()), str(reponse2.get()),str(reponse3.get())])  # Passer la valeur de reponse comme argument à mdp.py
#     root.destroy()

def plotting():
    global plotting_window, variables, rats, regions
    #global plotting_window, event, variable,  checkbox_var_rats, checkbox_var_regions, checkbox_var_region, checkbox_var_rat

    plotting_window=Tk()
    titre = variable + " of " + event
    
        
    titrePlotting = Label(plotting_window, borderwidth=3, relief="solid", text=titre, font=("Sans serif", 25), background="#483088", foreground="white")
    titrePlotting.place(x=250,y=0,width=1000)
    # plotting_window.geometry('900x1200+100+50')
    plotting_window.attributes('-fullscreen', True)
    plotting_window.title("Plot")
    plotting_window.resizable(True, True)
    plotting_window.configure(background="#808080")
    
    
    txtregions = Label(plotting_window, borderwidth=0, relief="solid", text="Which Region(s) ?", font=("Sans serif", 16), background="#808080", foreground="black")
    txtregions.place(x=20, y=70)
    
    txtrats = Label(plotting_window, borderwidth=0, relief="solid", text="Which Rat ?", font=("Sans serif", 16), background="#808080", foreground="black")
    txtrats.place(x=20, y=140)
    
    remark = Label(plotting_window, borderwidth=0, relief="solid", text="Please note, plotting detections take a lot of time ... \n You can select multiple regions only for counting", font=("Sans serif", 16), background="#808080", foreground="black")
    remark.place(x=200, y=750)
    
    rats=["1", "2", "3", "4"]
    regions=["HPC", "PL", "RSC"]
    
    positionx=300
    for region in regions:
    
        checkbox_var_region=tk.IntVar()
        checkbox_region=tk.Checkbutton(plotting_window,text=region,variable=checkbox_var_region,command=toggle_checkbox, font=("Sans serif", 15),bg="grey")
        checkbox_region.place(x=positionx,y=70)
        positionx+=150
        checkbox_var_regions[region] = checkbox_var_region
        
        
  
    
    positionx=300
    rats = ttk.Combobox(plotting_window, font=("Sans serif", 16), background="#FFFFFF", foreground="black")
    rats['values']=["Rat 1","Rat 2","Rat 3", "Rat 4"]
    rats.place(x=250, y=140)
    
    # for rat in rats: 
    #     checkbox_var_rat=tk.IntVar()
    #     checkbox_rat=tk.Checkbutton(plotting_window,text=rat,variable=checkbox_var_rat,command=toggle_checkbox, font=("Sans serif", 15),bg="grey")
    #     checkbox_rat.place(x=positionx,y=140)
    #     positionx+=150
    #     checkbox_var_rats[rat] = checkbox_var_rat

    # lbltexte2 = Label(plotting_window, borderwidth=0, relief="solid", text="Fill all the fields please", font=("Sans serif", 16), background="#808080", foreground="black")
    # lbltexte2.pack(pady=10)
    # rats=[]
    regions=[]

    close_button = Button(plotting_window, text="X", font=('ARIAL', 16), command=back)
    close_button.place(x=plotting_window.winfo_screenwidth() - 50, y=10, width=40, height=40)
    btnback = Button(plotting_window, text="Back", font=('ARIAL', 16), bg='#483088', fg='white', command=back)
    btnback.place(x=1100, y=140, width=100)
    
    btngo = Button(plotting_window, text="GO", font=('ARIAL', 16), bg='#483088', fg='white', command=display_plot)
    btngo.place(x=1100, y=500, width=100)


    
   

    plotting_window.mainloop()
    
def back():
    global plotting_window
    plotting_window.destroy()
    
def error(error_type):
    fenetre_incorrecte = Tk()
    fenetre_incorrecte.geometry('400x150+100+50')
    fenetre_incorrecte.title("Error")
    fenetre_incorrecte.resizable(False, False)
    fenetre_incorrecte.configure(background="#808080")
    
    if error_type==1:
        texte="Fill all the fields please "
    elif error_type==2:
        texte="You have to select 1 rat\n and 1 region at least"
    elif error_type==3:
        texte="You can chose multiple regions \n only if you are counting the events"

    lbltexte2 = Label(fenetre_incorrecte, borderwidth=0, relief="solid", text=texte, font=("Sans serif", 16), background="#808080", foreground="black")
    lbltexte2.pack(pady=10)
    
    

    fenetre_incorrecte.mainloop()

def close_window():
    root.destroy()  
    
    


def initialization():
    global events, variables, root 
    rats=["1", "2", "3", "4"]
    regions=["HPC", "PL", "RSC"]
    root = Tk()
    root.geometry('800x400+500+300')
    root.title("Plot")
    root.resizable(True, True)
    root.configure(background="#808080")
    
    
    # rats=["1", "2", "3", "4"]
    # regions=["HPC", "PL", "RSC"]
    
    # lbltitre = Label(root, borderwidth=3, relief=SUNKEN, text="Inscription", font=("Sans serif", 25), background="#483088", foreground="white")
    # lbltitre.place(x=480, y=0, width=600)
    
    txtvariables = Label(root, borderwidth=0, relief=SUNKEN, text="What do you want to plot ?", font=("Sans serif", 16), background="#808080", foreground="black")
    txtvariables.place(x=30, y=30)
    
    variables = ttk.Combobox(root,font=("Sans serif", 16), background="#808080", foreground="black")
    variables['values']=["Count","Amplitude","Duration", "Frequency"]
    variables.place(x=300, y=30)
    
    txtevents = Label(root, borderwidth=0, relief=SUNKEN, text="Which event ?", font=("Sans serif", 16), background="#808080", foreground="black")
    txtevents.place(x=30, y=100)
    
    #mettre un + et un - pour qu'ils puissent ajuster le nombre de personnes
    events = ttk.Combobox(root, font=("Sans serif", 16), background="#FFFFFF", foreground="black")
    events['values']=["Ripples","Spindles","Delta Waves"]
    events.place(x=300, y=100)
    
    
    close_button = Button(root, text="X", font=('ARIAL', 16), command=close_window)
    close_button.place(x=root.winfo_screenwidth() - 50, y=10, width=40, height=40)
    btnenregistrer = Button(root, text="Plot", font=('ARIAL', 16), bg='#483088', fg='white', command=launch_plot)
    btnenregistrer.place(x=400, y=200, width=100)
    # root.bind('<Return>',activate_button)
    root.mainloop()

checkbox_var_rats={}
checkbox_var_regions={}    
# rats=["1", "2", "3", "4"]
# regions=["HPC", "PL", "RSC"]    
initialization()



   
