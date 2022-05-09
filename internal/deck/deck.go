package deck

import (
	"fmt"
	"io/ioutil"
	"math/rand"
	"os"
	"strings"
	"time"
)

type Deck []string

func NewDeck() Deck {
	cards := Deck{}
	cardSuits := []string{"Spades", "Clubs", "Diamonds", "Hearts"}
	cardValues := []string{"Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"}
	for _, suit := range cardSuits {
		for _, value := range cardValues {
			cards = append(cards, fmt.Sprintf("%s of %s", value, suit))
		}
	}
	return cards.Shuffle()
}

func NewCustomDeck(nCards uint) Deck {
	cards := NewDeck()
	return cards[:nCards]
}

func (d Deck) Shuffle() Deck {
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(d), func(i, j int) { d[i], d[j] = d[j], d[i] })
	return d
}

func (d *Deck) Deal(handSize int) (*Deck, error) {
	if handSize > len(*d) {
		return nil, fmt.Errorf("error: Requested %d cards while %d are present", handSize, len(*d))
	}
	ret := (*d)[:handSize]
	*d = (*d)[handSize:]
	return &ret, nil
}

func (d Deck) ToString() string {
	return strings.Join([]string(d), ",")
}

//Legacy functions used in local env
func (d Deck) saveToFile(filename string) error {
	return ioutil.WriteFile(filename, []byte(d.ToString()), 0666)
}

func newDeckFromFile(filename string) Deck {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
	return Deck(strings.Split(string(bs), ","))
}

func (d Deck) print() {
	for i, card := range d {
		fmt.Println(i+1, card)
	}
}
