export default function Home() {
  return (
    <main>
      <h1>{{ values.platformName | title }} Platform</h1>
      <p>{{ values.description }}</p>
    </main>
  );
}

