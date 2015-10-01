//
//  LPParserClass.m
//  licenseProfessorMockUp
//
//  Created by Kyle Ju on 2015-01-13.
//  Copyright (c) 2015 Kenny Park. All rights reserved.
//

#import "LPParser.h"
#import "Question.h"
#import "Exam.h"
#import "LPCoreDataHelper.h"

@implementation LPParser

+(void) loadXML{
    //initalize sourceXML
    TBXML *sourceXML = [[TBXML alloc] initWithXMLFile:@"LicenseData.xml" error:nil];
    
    //First we will start by getting the root node of the XML file we are parsing using:
    TBXMLElement *rootElement = sourceXML.rootXMLElement;
    
    [self traverseXMLElement:rootElement];
}

+(void)traverseXMLElement:(TBXMLElement *)element {
    TBXMLElement *recordElement = [TBXML childElementNamed:@"record" parentElement:element];
    
    //Call the LPPCoreDataHelper class to retrieve NSManagementObjectContext
    NSManagedObjectContext *context = [LPCoreDataHelper managedObjectContext];
    
    do {
        if ([[TBXML elementName:recordElement] isEqualToString:@"record"])
        {
            
            TBXMLElement *questionIDElement = [TBXML childElementNamed:@"QuestionID" parentElement:recordElement];
            NSString *questionIDElementString = [TBXML textForElement:questionIDElement];
            
            TBXMLElement *questionElement = [TBXML childElementNamed:@"Question" parentElement:recordElement];
            NSString *questionElementString = [TBXML textForElement:questionElement];
            
            TBXMLElement *explanationElement = [TBXML childElementNamed:@"Explanation" parentElement:recordElement];
            NSString *explanationElementString = [TBXML textForElement:explanationElement];
            
            TBXMLElement *correctAnswerElement = [TBXML childElementNamed:@"Correct_Answer" parentElement:recordElement];
            NSString *correctAnswerElementString = [TBXML textForElement:correctAnswerElement];
            
            TBXMLElement *possibleAnswer1Element = [TBXML childElementNamed:@"Possible_Answer_1" parentElement:recordElement];
            NSString *possibleAnswer1ElementString = [TBXML textForElement:possibleAnswer1Element];
            
            TBXMLElement *possibleAnswer2Element = [TBXML childElementNamed:@"Possible_Answer_2" parentElement:recordElement];
            NSString *possibleAnswer2ElementString = [TBXML textForElement:possibleAnswer2Element];
            
            TBXMLElement *possibleAnswer3Element = [TBXML childElementNamed:@"Possible_Answer_3" parentElement:recordElement];
            NSString *possibleAnswer3ElementString = [TBXML textForElement:possibleAnswer3Element];
            
            TBXMLElement *possibleAnswer4Element = [TBXML childElementNamed:@"Possible_Answer_4" parentElement:recordElement];
            NSString *possibleAnswer4ElementString = [TBXML textForElement:possibleAnswer4Element];
            
            TBXMLElement *stateElement = [TBXML childElementNamed:@"State" parentElement:recordElement];
            NSString *stateElementString = [TBXML textForElement:stateElement];
            
            TBXMLElement *definitionElement = [TBXML childElementNamed:@"Definition" parentElement:recordElement];
            NSString *definitionElementString = [TBXML textForElement:definitionElement];
            
            TBXMLElement *mathElement = [TBXML childElementNamed:@"Math" parentElement:recordElement];
            NSString *mathElementString = [TBXML textForElement:mathElement];
            
            TBXMLElement *examElement = [TBXML childElementNamed:@"Exam" parentElement:recordElement];
            NSString *examElementString = [TBXML textForElement:examElement];
            
            TBXMLElement *materialChosenElement = [TBXML childElementNamed:@"MaterialChosen" parentElement:recordElement];
            NSString *materialChosenElementString = [TBXML textForElement:materialChosenElement];
            
            //covert questionID string into number
            int questionIDElementNumber = [questionIDElementString intValue];
            //covert correctAnswer string into number
            int correctAnswerElementNumber = [correctAnswerElementString intValue];
            //covert definition string into number
            int definitionElementNumber = [definitionElementString intValue];
            //covert math string into number
            int mathElementNumber = [mathElementString intValue];
            
            //****** core data part *****************
            Question *questionData = [NSEntityDescription insertNewObjectForEntityForName: @"Question" inManagedObjectContext:context];
            questionData.questionID = questionIDElementNumber;
            questionData.question = questionElementString;
            questionData.explanation = explanationElementString;
            questionData.correctAnswer = correctAnswerElementNumber;
            questionData.possibleAnswer1 = possibleAnswer1ElementString;
            questionData.possibleAnswer2 = possibleAnswer2ElementString;
            questionData.possibleAnswer3 = possibleAnswer3ElementString;
            questionData.possibleAnswer4 = possibleAnswer4ElementString;
            questionData.examState = stateElementString;
            questionData.definition = definitionElementNumber;
            questionData.math = mathElementNumber;
            questionData.exam = examElementString;
            questionData.materialChosen = materialChosenElementString;
            
            
            
            
            bool isExamNull = [examElementString isEqualToString:@"NULL"];
            if (!isExamNull){
                
                
                // conver exam Element string into int
                        int examElementNumber = [examElementString intValue];
                
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"examNo = %i", examElementNumber];
                NSError *error = nil;
                NSArray *fetchResult = [context executeFetchRequest:fetchRequest error: &error];
                
                if (!fetchResult || !fetchResult.count){
                    Exam *newExamEntity = [NSEntityDescription insertNewObjectForEntityForName: @"Exam" inManagedObjectContext:context];
                    questionData.designatedExam = newExamEntity;
                    newExamEntity.examNo = examElementNumber;
                    newExamEntity.location = stateElementString;
                    newExamEntity.examMaterialChosen = materialChosenElementString;
                    [newExamEntity addQuestionsObject:questionData];
                    
                    //********** adding titles *****
                    
                    int examElementNumber = [examElementString intValue];
                    NSString *prefixTitle;
                    if (examElementNumber >=1 && examElementNumber<=10){
                        prefixTitle = @"General Exam #";
                        newExamEntity.title = [NSString stringWithFormat:@"%@%i", prefixTitle, examElementNumber];
                    }
                    else if (examElementNumber >=15 && examElementNumber <= 24){
                        examElementNumber = examElementNumber - 14;
                        prefixTitle = @"General Exam #";
                        newExamEntity.title = [NSString stringWithFormat:@"%@%i", prefixTitle, examElementNumber];
                    }
                    else if (examElementNumber == 13 || examElementNumber == 14){
                        examElementNumber = examElementNumber - 12;
                        prefixTitle = @"Definitions Exam #";
                        newExamEntity.title = [NSString stringWithFormat:@"%@%i", prefixTitle, examElementNumber];
                    }
                    else if (examElementNumber == 27 || examElementNumber == 28){
                        examElementNumber = examElementNumber - 26;
                        prefixTitle = @"Definitions Exam #";
                        newExamEntity.title = [NSString stringWithFormat:@"%@%i", prefixTitle, examElementNumber];
                    }
                    else if (examElementNumber == 11 || examElementNumber == 12){
                        examElementNumber = examElementNumber - 10;
                        prefixTitle = @"Math Exam #";
                        newExamEntity.title = [NSString stringWithFormat:@"%@%i", prefixTitle, examElementNumber];
                    }
                    else if (examElementNumber == 25 || examElementNumber == 26){
                        examElementNumber = examElementNumber - 24;
                        prefixTitle = @"Math Exam #";
                        newExamEntity.title = [NSString stringWithFormat:@"%@%i", prefixTitle, examElementNumber];
                    }
                    else if (examElementNumber == 29){
                        prefixTitle = @"Financing";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 30){
                        prefixTitle = @"Fair practice";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 31){
                        prefixTitle = @"Selling Property";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 32){
                        prefixTitle = @"Listing property";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 33){
                        prefixTitle = @"Property Management";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 34){
                        prefixTitle = @"Transfer of Ownership";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 35){
                        prefixTitle = @"Financing";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 36){
                        prefixTitle = @"Real Property";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 37){
                        prefixTitle = @"Valuation / Appraisal";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 38){
                        prefixTitle = @"Contracts";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 39){
                        prefixTitle = @"Financing";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 40){
                        prefixTitle = @"Land Use Controls";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 41){
                        prefixTitle = @"Laws of Agency";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 42){
                        prefixTitle = @"Practice of Real Estate";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 43){
                        prefixTitle = @"Speecialty Areas";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 44){
                        prefixTitle = @"Transfer of Property";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 45){
                        prefixTitle = @"Property Ownership";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 46){
                        prefixTitle = @"Mandated Disclosure";
                        newExamEntity.title = prefixTitle;
                    }
                    else if (examElementNumber == 47){
                        prefixTitle = @"Valuation";
                        newExamEntity.title = prefixTitle;
                    }
                    else{
                        //create states specific titles
                        NSFetchRequest *newFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
                        newFetchRequest.predicate = [NSPredicate predicateWithFormat:@"(location == %@) AND (examMaterialChosen == %@)", stateElementString, materialChosenElementString];
                        NSError *error = nil;
                        NSArray *newFetchResult = [context executeFetchRequest:newFetchRequest error: &error];
                        unsigned long examNumber = newFetchResult.count;
                        NSString *stateSpecific = @" State Specific #";
                        prefixTitle = [NSString stringWithFormat:@"%@%@%lu", stateElementString, stateSpecific, examNumber];
                        newExamEntity.title = prefixTitle;
                        
                    }
                    
                }
                else {
                    Exam *existingExam = fetchResult[0];
                    [existingExam addQuestionsObject:questionData];
                }
            }
            
        }
        
    } while ((recordElement = recordElement->nextSibling));
    
    NSError *error = nil;
    if (! [context save: &error]){
        NSLog(@"%@", error);
    }
}





@end

