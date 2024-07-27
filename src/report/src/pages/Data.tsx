import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function Data() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Data</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle>Coming soon</CardTitle>
                    <CardDescription>With love and patience, nothing is impossible. -Daisaku Ikeda
                    </CardDescription>
                </CardHeader>
            </Card>
        </>
    )
}
