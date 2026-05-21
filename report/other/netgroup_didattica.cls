%Last modification: Oct 18, 2018

\NeedsTeXFormat{LaTeX2e}
\ProvidesPackage{netgroup_didattica}
\RequirePackage{graphicx}
\RequirePackage{setspace}
% Required to define the \begin{comment] section.
\RequirePackage{comment}


\newif\ifexercise \exercisefalse
\DeclareOption{exercise}{\exercisetrue}
\ProcessOptions

\ifexercise
    \LoadClass[a4paper]{scrreprt}
\else
    \LoadClass[a4paper]{scrartcl}
%    \LoadClass[a4paper,12pt]{scrartcl}
%    \LoadClass{scrartcl}
\fi

% Package required for custom margins
\RequirePackage{anysize}
% Change the following line if you want to change the margins
%\marginsize{left}{right}{top}{bottom}
\marginsize{2cm}{2cm}{1.5cm}{2cm}


\RequirePackage{subfigure}
\RequirePackage[usenames,dvipsnames]{color}
%\RequirePackage[usenames,dvipsnames]{xcolor}
\RequirePackage{enumitem}

\newcommand{\HRule}{\rule{\linewidth}{0.5mm}}
\newcommand\university[1]{\gdef\@university{#1}}
\newcommand\logo[1]{\gdef\@logo{#1}}

% Definiamo il comando \correct
%\newcommand{\correct}{}
\newcommand{\correct}[1]{\textcolor{blue}{#1}}
%\newcommand{\correct}[1]{\textbf{\textcolor{blue}{#1}}}

\newcommand\course[1]{\gdef\@course{#1}}
\newcommand\titlecaption[1]{\gdef\@titlecaption{#1}}

\@ifundefined{@university}{\def\@university{Politecnico di Torino}}{}
\@ifundefined{@logo}{\def\@logo{}}{}
% course: e.g., Computer Networks
\@ifundefined{@course}{\def\@course{}}{}
\@ifundefined{@titlecaption}{\def\@titlecaption{}}{}

% This introduces some more space between paragraphs
\setlength{\parskip}{1ex plus 0.5ex minus 0.2ex}


%Define a new counter for exercise numbering
%Please note that this requires that chapters are defined in your document.
%In case you have no chapters, replace the definition with the one commented below.
%\newcounter{exercise}[chapter]
%\newcounter{exercise}

%Set the initial value to one
%\setcounter{exercise}{1}
%Define a command that prints the value of the counter and also increments its value
%\newcommand{\exnumber}{\addtocounter{exercise}{1}\arabic{exercise}}

%To use the counter, simply place '\exnumber' in your latex.
%To reset the counter, simply use the '\setcounter{exercise}{1}' command.
%FULVIO Apr 2013: il problema e' che con questo comando i numeri degli esercizi sono diversi nel testo e nell'indice. Ad es, in questo caso l'esercizio 1 e' tale nel testo, ma nell'indice compare come esercizio 2.


\renewcommand{\maketitle}{%

\begin{titlepage}
 
\begin{center}
 
 
% Upper part of the page
 
%\textsc{\LARGE \@university}\\[1.5cm]
\IfFileExists{\@logo}{\includegraphics[width=0.50\textwidth]{\@logo}\\[1cm]}

 
% Title

% This command defines the title and handles also the case in which the title is so long that requires two lines
{ \begin{spacing}{1.2} \huge \bfseries \textcolor{RoyalBlue}{\@title} \end{spacing}}
% This is the previous command that worked in case the title was on a single line; in this case, the space
% for 'titlecaption' was 4.7cm instead of 4.2
%{\huge \bfseries \textcolor{RoyalBlue}{\@title}}\\[0.2cm]

\textcolor{RoyalBlue}{\HRule} \\[0.5cm]
{ \Large \bfseries \textcolor{RoyalBlue}{\@course}}\\[7cm]
%{ \Large \bfseries \textcolor{RoyalBlue}{\@titlecaption}}\\[4.2cm]

{\large \@author}\\[0.3cm]


\vfill
 

 
% Bottom of the page
{\large \today}
 
\end{center}
 
\end{titlepage}}


%This package is needed because we need to re-define alltt
% This new environment command enables to show text using the typewriter font
\RequirePackage{alltt}

\newenvironment{code}
  {\endgraf\small\alltt}
  {\endalltt}

% As an additional option, the following command changes the default font for typewriter text.
% A list of available fonts in Latex is shown here:
%     http://www.tug.dk/FontCatalogue/typewriterfonts.html
%\renewcommand{\ttdefault}{txtt}

% Additional link: List of Latex font families, sizes and styles:
%   https://www.overleaf.com/learn/latex/Font_sizes,_families,_and_styles


% Previous version of this style used 'verbatim' instead of 'alltt'
% However verbatim does not allow additional formatting within the text (e.g., italic, change font color)
%
%\RequirePackage{verbatim}
%
%\newenvironment{code}
%  {\endgraf\small\verbatim}
%  {\endverbatim}




\definecolor{bluetabcolor}{rgb}{.3,.5,.75}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newenvironment{bluetabTwo}[2]%
{
	\arrayrulecolor{bluetabcolor}
	\renewcommand{\arraystretch}{1.15}
	
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{}}{%
		\begin{longtable}{|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{}}{%
		\begin{longtable}{|c|m{#2}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|m{#2}<{\centering}|}
	}{
	}}}}
	
}	
{
	\end{longtable}
	
	\renewcommand{\arraystretch}{1}
	\arrayrulecolor{black}
}

\newcommand{\bluetabHeaderTwo}[2]{%
	\rowcolor[rgb]{.3,.5,.75} {\footnotesize \sffamily \bfseries \textcolor{white}{#1}} & {\footnotesize \sffamily \bfseries \textcolor{white}{#2}} \\
	\hline
	
}

\newcommand{\bluetabRowTwo}[2]{%
	\footnotesize \sffamily #1 & \footnotesize \sffamily #2 \\%
	\hline
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newenvironment{bluetabThree}[3]%
{
	\arrayrulecolor{bluetabcolor}
	\renewcommand{\arraystretch}{1.15}
	
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}}{%
		\begin{longtable}{|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{}}{%
		\begin{longtable}{|c|c|m{#3}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|}
	}{
	\ifthenelse{\equal{#1}{}\AND \NOT\equal{#2}{}\AND \NOT\equal{#3}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|m{#3}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|m{#3}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|m{#3}<{\centering}|}
	}{
	}}}}}}}}
	
}	
{
	\end{longtable}
	
	\renewcommand{\arraystretch}{1}
	\arrayrulecolor{black}
}

\newcommand{\bluetabHeaderThree}[3]{%
	\rowcolor[rgb]{.3,.5,.75}  {\footnotesize \sffamily \bfseries \textcolor{white}{#1}} & {\footnotesize \sffamily \bfseries \textcolor{white}{#2}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#3}} \\
	\hline

}

\newcommand{\bluetabRowThree}[3]{%
	\footnotesize \sffamily #1 & \footnotesize \sffamily #2 & \footnotesize \sffamily #3 \\%
	\hline
}

\newcommand{\bluetabMultiThree}[3]{%
	\ifthenelse{\equal{#3}{}}{%
		\footnotesize \sffamily #1 & \multicolumn{2}{c|}{\footnotesize \sffamily #2} \\
	}{
		\footnotesize \sffamily #1 & \multicolumn{2}{>{\centering}m{#3}|}{\footnotesize \sffamily #2} \\
	}
	\hline
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newenvironment{bluetabFour}[4]%
{
	\arrayrulecolor{bluetabcolor}
	\renewcommand{\arraystretch}{1.15}
	
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|c|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|c|c|c|m{#4}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|m{#4}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|m{#4}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{}\AND \NOT\equal{#2}{}\AND \NOT\equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|}
	}{
	\ifthenelse{\equal{#1}{}\AND \NOT\equal{#2}{}\AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|m{#4}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|m{#4}<{\centering}}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|m{#4}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|m{#4}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|m{#4}<{\centering}|}
	}{
	}}}}}}}}}}}}}}}}
	
}	
{
	\end{longtable}
	
	\renewcommand{\arraystretch}{1}
	\arrayrulecolor{black}
}

\newcommand{\bluetabHeaderFour}[4]{%
	\rowcolor[rgb]{.3,.5,.75}  {\footnotesize \sffamily \bfseries \textcolor{white}{#1}} & {\footnotesize \sffamily \bfseries \textcolor{white}{#2}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#3}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#4}} \\
	\hline

}

\newcommand{\bluetabRowFour}[4]{%
	\footnotesize \sffamily #1 & \footnotesize \sffamily #2 & \footnotesize \sffamily #3 & \footnotesize \sffamily #4\\%
	\hline
}

\newcommand{\bluetabMultiFour}[3]{%
	\ifthenelse{\equal{#3}{}}{%
		\footnotesize \sffamily #1 & \multicolumn{3}{c|}{\footnotesize \sffamily #2} \\
	}{
		\footnotesize \sffamily #1 & \multicolumn{3}{>{\centering}m{#3}|}{\footnotesize \sffamily #2} \\
	}
	\hline
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newenvironment{bluetabFive}[5]%
{
	\arrayrulecolor{bluetabcolor}
	\renewcommand{\arraystretch}{1.15}
	
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|c|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|c|c|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|c|c|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}\AND \NOT\equal{#4}{}\AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|c|c|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	%%%%%%%%%%%%%%%%%%%
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}\AND \NOT\equal{#4}{}\AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|m{#5}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|m{#5}<{\centering}|}
	}{
	
	}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
}	
{
	\end{longtable}
	
	\arrayrulecolor{black}
	\renewcommand{\arraystretch}{1}
}

\newcommand{\bluetabHeaderFive}[5]{%
	\rowcolor[rgb]{.3,.5,.75}{\footnotesize \sffamily \bfseries \textcolor{white}{#1}} & {\footnotesize \sffamily \bfseries \textcolor{white}{#2}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#3}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#4}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#5}} \\%
	\hline

}

\newcommand{\bluetabRowFive}[5]{%
	\footnotesize \sffamily #1 & \footnotesize \sffamily #2 & \footnotesize \sffamily #3 & \footnotesize \sffamily #4 & \footnotesize \sffamily #5 \\%
	\hline
}

\newcommand{\bluetabMultiFive}[3]{%
	\ifthenelse{\equal{#3}{}}{%
		\footnotesize \sffamily  #1 & \multicolumn{4}{c|}{\footnotesize \sffamily #2} \\
	}{
		\footnotesize \sffamily  #1 & \multicolumn{4}{>{\centering}m{#3}|}{\footnotesize \sffamily #2} \\
	}
	\hline
}

\newcommand{\bluetabMultiAllFive}[2]{%
	\if!#2!
		\multicolumn{5}{|c|}{\footnotesize \sffamily #1} \\
	\else
		\multicolumn{5}{|>{\centering}m{#2}|}{\footnotesize \sffamily #1} \\
	\fi
	\hline
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newenvironment{bluetabSix}[6]%
{
	\arrayrulecolor{bluetabcolor}
	\renewcommand{\arraystretch}{1.15}
	
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|c|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|c|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|c|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|c|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|c|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|c|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}\AND \NOT\equal{#4}{}\AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|c|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}\AND \NOT\equal{#4}{}\AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|c|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|c|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|c|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|c|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	%%%%%%%%%%%%%%%%%%%
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}\AND \NOT\equal{#4}{}\AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \equal{#3}{}\AND \NOT\equal{#4}{}\AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|c|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|c|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|c|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|c|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|c|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|c|m{#6}<{\centering}|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|c|}
	}{
	\ifthenelse{\NOT\equal{#1}{} \AND \NOT\equal{#2}{} \AND \NOT\equal{#3}{} \AND \NOT\equal{#4}{} \AND \NOT\equal{#5}{} \AND \NOT\equal{#6}{}}{%
		\begin{longtable}{|>{\centering}m{#1}|>{\centering}m{#2}|>{\centering}m{#3}|>{\centering}m{#4}|>{\centering}m{#5}|m{#6}<{\centering}|}
	}{
	}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
	
}	
{
	\end{longtable}
	
	\renewcommand{\arraystretch}{1}
	\arrayrulecolor{black}
}

\newcommand{\bluetabHeaderSix}[6]{%
	\rowcolor[rgb]{.3,.5,.75}  {\footnotesize \sffamily \bfseries \textcolor{white}{#1}} & {\footnotesize \sffamily \bfseries \textcolor{white}{#2}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#3}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#4}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#5}} & {\footnotesize \sffamily \bfseries \textcolor{white} {#6}} \\
	\hline
}

\newcommand{\bluetabRowSix}[6]{%
	\footnotesize \sffamily #1 & \footnotesize \sffamily #2 & \footnotesize \sffamily #3 & \footnotesize \sffamily #4 & \footnotesize \sffamily #5 & \footnotesize \sffamily #6 \\%
	\hline
}

\newcommand{\bluetabMultiSix}[3]{%
	\ifthenelse{\equal{#3}{}}{%
		\footnotesize \sffamily #1 & \multicolumn{5}{c|}{\footnotesize \sffamily #2} \\
	}{
		\footnotesize \sffamily #1 & \multicolumn{5}{>{\centering}m{#3}|}{\footnotesize \sffamily #2} \\
	}
	\hline
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\endinput
