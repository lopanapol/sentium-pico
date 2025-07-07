import json
import os
import random
import re

class BabyBrain:
    def __init__(self, brain_file="baby_brain_knowledge.json"):
        self.script_dir = os.path.dirname(__file__)
        self.brain_file = os.path.join(self.script_dir, brain_file)
        self.phoneme_activations = {}
        self.syllable_patterns = {}
        self.word_activations = {}
        self.developmental_stage = 0 # 0: cooing, 1: babbling, 2: single words
        self._load_brain()

    def _load_brain(self):
        if os.path.exists(self.brain_file):
            with open(self.brain_file, 'r') as f:
                data = json.load(f)
                self.phoneme_activations = data.get('phoneme_activations', {})
                self.syllable_patterns = data.get('syllable_patterns', {})
                self.word_activations = data.get('word_activations', {})
                self.developmental_stage = data.get('developmental_stage', 0)
        
    def _save_brain(self):
        data = {
            'phoneme_activations': self.phoneme_activations,
            'syllable_patterns': self.syllable_patterns,
            'word_activations': self.word_activations,
            'developmental_stage': self.developmental_stage
        }
        with open(self.brain_file, 'w') as f:
            json.dump(data, f, indent=4)

    def _get_activated_phonemes(self, phoneme_type='all'):
        # Select phonemes based on activation levels (higher activation = more likely)
        activated_phonemes = []
        for phoneme, activation in self.phoneme_activations.items():
            if phoneme_type == 'vowel' and phoneme not in 'aeiou':
                continue
            if phoneme_type == 'consonant' and phoneme in 'aeiou':
                continue
            # Add phoneme multiple times based on activation to increase selection probability
            activated_phonemes.extend([phoneme] * int(activation * 10 + 1))
        
        if not activated_phonemes:
            return []
        return activated_phonemes

    def _generate_syllable(self):
        # Prioritize learned syllable patterns
        if self.syllable_patterns:
            structure = random.choices(list(self.syllable_patterns.keys()), weights=list(self.syllable_patterns.values()), k=1)[0]
        else:
            # Fallback to basic structures if no patterns learned yet
            structure = random.choice(['V', 'CV'])

        syllable = ""
        for char_type in structure:
            if char_type == 'V': # Vowel
                syllable += random.choice(self._get_activated_phonemes('vowel'))
            elif char_type == 'C': # Consonant
                syllable += random.choice(self._get_activated_phonemes('consonant'))
        return syllable

    def generate_vocalization(self, sentiment):
        print(f"DEBUG: Current developmental stage: {self.developmental_stage}")
        print(f"DEBUG: Current phoneme activations: {self.phoneme_activations}")
        print(f"DEBUG: Current syllable patterns: {self.syllable_patterns}")
        print(f"DEBUG: Current word activations: {self.word_activations}")

        if self.developmental_stage == 0: # Cooing phase
            available_vowels = self._get_activated_phonemes('vowel')
            available_consonants = self._get_activated_phonemes('consonant')
            print(f"DEBUG: Available vowels: {available_vowels}")
            print(f"DEBUG: Available consonants: {available_consonants}")

            if not available_vowels and not available_consonants:
                return "" # Truly empty vocalization if nothing learned

            if sentiment == "positive":
                if random.random() < 0.7 and available_consonants and available_vowels: # Chance for CV sound
                    return random.choice(available_consonants).capitalize() + random.choice(available_vowels)
                elif available_vowels: # Vowel repetition
                    return random.choice(available_vowels).capitalize() * random.randint(2, 4)
                else:
                    return "" # Fallback if no suitable phonemes
            elif sentiment == "negative":
                if random.random() < 0.5 and available_consonants and available_vowels: # Chance for short, sharp sound
                    return random.choice(available_consonants).capitalize() + random.choice(available_vowels)
                elif available_vowels:
                    return random.choice(available_vowels).capitalize() * random.randint(1, 3)
                else:
                    return "" # Fallback if no suitable phonemes
            else: # Neutral
                if random.random() < 0.6 and available_consonants and available_vowels: # Chance for simple babble
                    return random.choice(available_consonants).capitalize() + random.choice(available_vowels)
                elif available_vowels:
                    return random.choice(available_vowels).capitalize()
                else:
                    return "" # Fallback if no suitable phonemes
        
        elif self.developmental_stage == 1: # Babbling phase
            num_syllables = random.randint(1, 3)
            vocalization = ""
            for _ in range(num_syllables):
                vocalization += self._generate_syllable()
                if random.random() < 0.5: # Add repetition
                    vocalization += vocalization[-len(self._generate_syllable()):] # Repeat last syllable
            return vocalization.capitalize()

        elif self.developmental_stage >= 2: # Early words phase
            # Prioritize words with higher activation
            activated_words = []
            for word, activation in self.word_activations.items():
                activated_words.extend([word] * int(activation * 10 + 1))

            if activated_words and random.random() < 0.7: # Try to use a learned word
                word = random.choice(activated_words)
                if sentiment == "positive":
                    return word.capitalize()
                elif sentiment == "negative":
                    return word.capitalize()
                else:
                    return word.capitalize()
            else: # Fallback to babbling or simple sounds
                return self.generate_vocalization(sentiment) # Recursively call for babbling/cooing

    def learn_from_word(self, word):
        word_lower = word.lower()

        # Activate word neuron
        self.word_activations[word_lower] = self.word_activations.get(word_lower, 0) + 1

        # Activate phoneme neurons
        for char in word_lower:
            if char.isalpha():
                self.phoneme_activations[char] = self.phoneme_activations.get(char, 0) + 1
        print(f"DEBUG: Phoneme activations after learning '{word_lower}': {self.phoneme_activations}")
        
        # Learn syllable patterns (simple C/V patterns for now)
        vowels = 'aeiou'
        for i in range(len(word_lower) - 1):
            p1 = word_lower[i]
            p2 = word_lower[i+1]
            pattern = ''
            if p1.isalpha():
                pattern += 'V' if p1 in vowels else 'C'
            if p2.isalpha():
                pattern += 'V' if p2 in vowels else 'C'
            
            if pattern and len(pattern) == 2: # Only consider CV, VC, VV, CC patterns
                self.syllable_patterns[pattern] = self.syllable_patterns.get(pattern, 0) + 1

        # Update developmental stage
        if len(self.phoneme_activations) > 10 and self.developmental_stage < 1:
            self.developmental_stage = 1 # Move to babbling
        
        if len(self.word_activations) > 5 and self.developmental_stage < 2:
            self.developmental_stage = 2 # Move to early words

        self._save_brain()
