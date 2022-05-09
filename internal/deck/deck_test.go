package deck

import (
	"os"
	"testing"
)

func TestNewDeck(t *testing.T) {
	d := NewDeck()

	if len(d) != 16 {
		t.Errorf("Expected deck length of 16, got: %d", len(d))
	}

	if d[0] != "Ace of Spades" {
		t.Errorf("Expected first elem to be Ace of Spades, got: %s", d[0])
	}

	if d[len(d)-1] != "Four of Hearts" {
		t.Errorf("Expected first elem to be Four of Hearts, got: %s", d[len(d)-1])
	}
}

func TestSaveToFileAndNewDeckFromFile(t *testing.T) {
	os.Remove("_decktesting")

	savedDeck := NewDeck()
	savedDeck.saveToFile("_decktesting")
	loadedDeck := newDeckFromFile("_decktesting")

	if len(loadedDeck) != 16 {
		t.Errorf("Expected deck length of 16, got: %d", len(loadedDeck))
	}

	if loadedDeck[0] != "Ace of Spades" {
		t.Errorf("Expected first elem to be Ace of Spades, got: %s", loadedDeck[0])
	}

	if loadedDeck[len(loadedDeck)-1] != "Four of Hearts" {
		t.Errorf("Expected first elem to be Four of Hearts, got: %s", loadedDeck[len(loadedDeck)-1])
	}

	os.Remove("_decktesting")
}
